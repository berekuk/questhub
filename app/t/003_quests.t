use strict;
use warnings;
use utf8;

use Test::More tests => 12;
use Test::Deep;
#use EasyMocker;
#use Sub::Override;
#use Test::MockModule;

use JSON;
use Data::Dumper;

# the order is important
use Dancer qw();
use Play;
use Dancer::Test;


#--
my $quests_data = {
    1 => {
        name    => 'name_1',
        user    => 'user_1',
        status  => 'open',
    },
    2 => {
        name    => 'name_2',
        user    => 'uaer_2',
        status  => 'open',
    },
    3 => {
        name    => 'name_3',
        user    => 'uaer_3',
        status  => 'closed',
    },
};


#--- Init
my ( $quests, $collection, $ids );
{
    $ENV{TEST_DB} = 'play_test';

    #--
    $quests     = Play::Quests->new;
    $collection = $quests->collection;

    _init_db_data();

    #-- Чиним UTF
    use Test::Builder;
    for my $fh (Test::Builder->new()->todo_output, Test::Builder->new()->failure_output, Test::Builder->new()->output) {
        binmode($fh, ":encoding(utf8)");
    }

#    my $mockSVN = new Test::MockModule('Dancer::Session');
#    $mockSVN->mock( log => sub {
#        my ( $self, $REPOSITORY_URL, $min_rev, $max_rev, $discover_changed_paths, $strict_node_history, $SUB ) = @_;

}


####
{
    my $testname = 'Check list, get all - OK';
    my $got         = [ sort { $a->{_id} cmp $b->{_id} } @{ $quests->list({}) } ];
    my $expect      = [ sort { $a->{_id} cmp $b->{_id} } values %$quests_data ];
    cmp_deeply( $got, $expect, $testname )
        or note explain 'got',    $got,
                        'expect', $expect;
}


####
{
    my $testname = 'Select by params, get all';
    my $response    = dancer_response GET => '/api/quests';

    #--
    my $subtestname = 'Select by params, get all, status - OK';
    my $got         = $response->{status};
    my $expect      = 200;
    is $got, $expect, $subtestname
        or note explain 'got',    $got,
                        'expect', $expect;

    #--
    $subtestname = 'Select by params, get all, data - OK';
    $got         = [ sort { $a->{_id} cmp $b->{_id} } @{ JSON::decode_json( $response->{content} ) } ];
    $expect      = [ sort { $a->{_id} cmp $b->{_id} } values %$quests_data ];
    cmp_deeply( $got, $expect, $subtestname )
        or note explain 'got',    $got,
                        'expect', $expect;
}

####
{
    my $testname = 'Select by params, status closed';
    my $response    = dancer_response GET => '/api/quests', { params => { status => 'closed' } };

    #--
    my $subtestname = 'Select by params, status closed, status - OK';
    my $got         = $response->{status};
    my $expect      = 200;
    is $got, $expect, $subtestname
        or note explain 'got',    $got,
                        'expect', $expect;

    #--
    $subtestname = 'Select by params, status closed, data - OK';
    $got         = JSON::decode_json( $response->{content} );
    $expect      = [ $quests_data->{3} ];
    cmp_deeply( $got, $expect, $subtestname )
        or note explain 'got',    $got,
                        'expect', $expect;
}


####
{
    my $testname    = 'Get by ID';

    my $id          =  $quests_data->{1}->{_id};
    my $response    = dancer_response GET => '/api/quest/'.$id;

    #--
    my $subtestname = 'Get by ID - OK';
    my $got         = JSON::decode_json( $response->{content} );
    my $expect      = $quests_data->{1};
    cmp_deeply( $got, $expect, $subtestname )
        or note explain 'got',    $got,
                        'expect', $expect;
}


####
{
    my $testname    = 'Edit specified quest';

    my $edited_quest = $quests_data->{1};
    my $id          = $edited_quest->{_id};
    local $edited_quest->{name} = 'name_11'; # Change

    #---
    my $old_login = Dancer::session->{login};
    Dancer::session login => $edited_quest->{user};

    my $response    = dancer_response POST => '/api/quest/'.$id, { params => { name => $edited_quest->{name} } };

    #--
    my $subtestname = 'Edit specified quest, status - OK';
    my $got         = $response->{status};
    my $expect      = 200;
    is $got, $expect, $subtestname
        or note explain 'content', $response->{content};

    #--
    $subtestname = 'Edit specified quest - OK';
    $got         = JSON::decode_json( $response->{content} );
                   delete $got->{id};
    $expect      = { status  => 'ok' };
    cmp_deeply( $got, $expect, $subtestname )
        or note explain 'got',    $got,
                        'expect', $expect;

    #---
    $subtestname    = 'Edit specified quest, check updated - OK';
    $got            = $collection->find_one({
                        _id => MongoDB::OID->new(value => $id)
                      });
                      Play::Quests::_prepare_quest( undef, $got );
    $expect         = $edited_quest;
    cmp_deeply( $got, $expect, $subtestname )
        or note explain 'got',    $got,
                        'expect', $expect;

    #-- restore session login
    Dancer::session( login => $old_login ) if $old_login;

    #--- restore data
    _init_db_data();
}


####
{
    my $testname = 'Add new';

    my $user = 'user_4';
    my $new_record = {
        user    => $user,
        name    => 'name_4',
        status  => 'open',
    };

    #---
    my $old_login = Dancer::session->{login};
    Dancer::session login => $user;

    my $response    = dancer_response POST => '/api/quest', { params => $new_record };

    #--
    my $subtestname = 'Add new, status - OK';
    my $got         = $response->{status};
    my $expect      = 200;
    is $got, $expect, $subtestname
        or note explain 'content', $response->{content};

    if ( ref $response->{content} eq 'GLOB' ) {
        my $fh = $response->{content};
        local $/ = undef;
        $response->{content} = [ <$fh> ];
    }

    #--
    $subtestname = 'Add new, data - OK';
    $got         = JSON::decode_json( $response->{content} );
    my $got_id = delete $got->{id};
    $expect      = { status  => 'ok' };
    cmp_deeply( $got, $expect, $subtestname )
        or note explain 'got',    $got,
                        'expect', $expect;

    #---
    $subtestname    = 'Add new, check inserted - OK';
    $got            = $collection->find_one( $new_record );
    Play::Quests::_prepare_quest( undef, $got );
    $new_record->{_id} = $got_id;
    $expect         = $new_record;
    cmp_deeply( $got, $expect, $subtestname )
        or note explain 'got',    $got,
                        'expect', $expect;

    #-- restore session login
    Dancer::session( login => $old_login ) if $old_login;

    #--- restore data
    _init_db_data();
}


#    warn Data::Dumper->Dump( [ Dancer::session ], ['session qweqwe'] );
#    my $mock_ya_init = new Test::MockModule('Dancer::Session::YAML');
#    $mock_ya_init->mock( init       => sub {1} );
#    $mock_ya_init->mock( create     => sub { $fake_session } );
#    $mock_ya_init->mock( retrieve   => sub { $fake_session } );
#    $mock_ya_init->mock( flush      => sub { $fake_session } );

sub _init_db_data {

    #--- Delete all
    $collection->remove({});

    #-- Insert
    foreach ( keys %$quests_data ) {
        delete $quests_data->{$_}->{_id};
        my $OID = $collection->insert( $quests_data->{$_} ); # MongoDB::OID
        $quests_data->{$_}->{_id} = $OID->to_string; #
        $ids->{ $_ } = $OID;
    }
}