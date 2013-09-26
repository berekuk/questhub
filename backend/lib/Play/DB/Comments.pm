package Play::DB::Comments;

=head1 OBJECT FORMAT

See C<CommentParams> definition in L<Play::Types>.

=head1 METHODS

=over

=cut

use Moo;
use Play::DB::Role::PushPull;
with
    'Play::DB::Role::Common',
    PushPull(field => 'likes', except_field => 'author', push_method => 'like', pull_method => 'unlike');

use Play::Mongo;
use Play::DB qw(db);

use Types::Standard qw(Str Dict HashRef ArrayRef);
use Type::Params qw(compile);
use Play::Types qw(Entity Id Login CommentParams);

use Play::Markdown qw(markdown);

has 'secret_collection' => (
    is => 'lazy',
);
sub _build_secret_collection { Play::Mongo->db->get_collection('secret_comments') }

sub _prepare_comment {
    my $self = shift;
    my ($comment) = @_;
    $comment->{ts} = $comment->{_id}->get_time;
    $comment->{_id} = $comment->{_id}->to_string;
    $comment->{type} ||= 'text';
    return $comment;
}

sub body2html {
    my $self = shift;
    my $check = compile(Str, Str);
    my ($body, $realm) = $check->(@_);

    local $Play::Markdown::REALM = $realm;
    local @Play::Markdown::MENTIONS = ();

    my $html = markdown($body);

    my @mentions = @Play::Markdown::MENTIONS;
    return $html, { mentions => \@mentions };
}

=item B<add($comment_params)>

=cut
sub add {
    my $self = shift;
    my $check = compile(CommentParams);
    my ($params) = $check->(@_);

    my $realm;
    if ($params->{entity} eq 'quest') {
        my $quest = db->quests->get($params->{eid}) or die "quest '$params->{eid}' not found";
        $realm = $quest->{realm};
        db->quests->bump($params->{eid});
    }
    elsif ($params->{entity} eq 'stencil') {
        my $stencil = db->stencils->get($params->{eid}) or die "stencil '$params->{eid}' not found";
        $realm = $stencil->{realm};
        db->stencils->bump($params->{eid});
    }
    else {
        die "Unknown entity '$params->{entity}'";
    }

    if ($params->{type} and $params->{type} eq 'secret') {
        die "Only quests support secret comments" unless $params->{entity} eq 'quest';
        my $secret_id = $self->secret_collection->insert({
            body => $params->{body},
        }, { safe => 1 });
        $params->{secret_id} = $secret_id->to_string;
        delete $params->{body};
    }

    my $id = $self->collection->insert($params, { safe => 1 });

    db->events->add({
        type => 'add-comment',
        author => $params->{author},
        comment_id => $id->to_string,
        realm => $realm,
    });

    return { _id => $id->to_string };
}

=item B<list($entity, $eid)>

Get all comments for a quest or a stencil or another entity.

I<$entity> can be either C<quest> or C<stencil>.

=cut
# TODO - pager?
sub list {
    my $self = shift;
    my $check = compile(Entity, Id);
    my ($entity, $eid) = $check->(@_);

    my @comments = $self->collection->find({
        entity => $entity,
        eid => $eid,
    })->sort({
        _id => 1
    })->all;
    $self->_prepare_comment($_) for @comments;

    return \@comments;
}

=item B<get_one($id)>

Get a single comment by its id.

=cut
sub get_one {
    my $self = shift;
    my $check = compile(Id);
    my ($comment_id) = $check->(@_);

    my $comment = $self->collection->find_one({
        _id => MongoDB::OID->new(value => $comment_id)
    });
    die "comment $comment_id not found" unless $comment;
    $self->_prepare_comment($comment);
    return $comment;
}

=item B<bulk_get($ids_arrayref)>

Get multiple comments by their ids.

=cut
sub bulk_get {
    my $self = shift;
    my $check = compile(ArrayRef[Id]);
    my ($ids) = $check->(@_);

    my @comments = $self->collection->find({
        '_id' => {
            '$in' => [
                map { MongoDB::OID->new(value => $_) } @$ids
            ]
        }
    })->all;
    $self->_prepare_comment($_) for @comments;

    return {
        map {
            $_->{_id} => $_
        } @comments
    };
}


=item B<bulk_count($entity, $eids_arrayref)>

Get number of comments for each entity in given set.

=cut
sub bulk_count {
    my $self = shift;
    my $check = compile(Entity, ArrayRef[Id]);
    my ($entity, $ids) = $check->(@_);

    # TODO - upgrade MongoDB to 2.2+ and use aggregation
    my @comments = $self->collection->find({
        entity => $entity,
        eid => { '$in' => $ids },
        body => { '$exists' => 1 },
    })->all;
    my %stat;
    for (@comments) {
        $stat{ $_->{eid} }++;
    }
    return \%stat;
}

=item B<< remove({ id => $id, user => $login }) >>

=cut
sub remove {
    my $self = shift;
    my $check = compile(Dict[
        id => Id,
        user => Login,
    ]);
    my ($params) = $check->(@_);

    my $result = $self->collection->remove(
        {
            _id => MongoDB::OID->new(value => $params->{id}),
            author => $params->{user},
        },
        { just_one => 1, safe => 1 }
    );
    die "comment not found or access denied" unless $result->{n} == 1;
    return;
}

=item B<< update({ id => $id, body => $body, user => $user) >>

=cut
sub update {
    my $self = shift;
    my $check = compile(Dict[
        id => Id,
        body => Str,
        user => Login,
    ]);
    my ($params) = $check->(@_);

    my $id = delete $params->{id};

    my $comment = $self->get_one($id);
    unless ($comment->{author} eq $params->{user}) {
        die "access denied";
    }

    delete $comment->{_id};
    my $comment_after_update = { %$comment, %$params };
    $self->collection->update(
        { _id => MongoDB::OID->new(value => $id) },
        $comment_after_update
    );

    return $id;
}

sub reveal {
    my $self = shift;
    my $check = compile(Id);
    my ($id) = $check->(@_);

    my $comment = $self->get_one($id);
    unless ($comment->{type} eq 'secret') {
        die "$id is not a secret comment";
    }

    my ($secret) = $self->secret_collection->find_one({
        _id => MongoDB::OID->new(value => $comment->{secret_id}),
    });

    my $result = $self->collection->update(
        { _id => MongoDB::OID->new(value => $id) },
        {
            '$set' => { body => $secret->{body} },
            '$unset' => { secret_id => '' },
        },
        { safe => 1 }
    );
    my $updated = $result->{n};
    unless ($updated) {
        die "Can't update comment body, huh.";
    }

    # cleanup
    $self->secret_collection->remove(
        {
            _id => MongoDB::OID->new(value => $comment->{secret_id}),
        }
    );
}

=over

=cut

1;
