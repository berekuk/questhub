package Play::Route::SEO;

use Dancer ':syntax';
prefix '/seo';

use DateTime;
use DateTime::Format::RFC3339;

use Play::DB qw(db);
use Play::Markdown qw(markdown);
use Play::Config qw(setting);

my $rfc3339 = DateTime::Format::RFC3339->new;

get '/quest/:id' => sub {
    my $quest = db->quests->get(param('id'));
    redirect "/realm/$quest->{realm}/quest/".param('id');
};

get '/realm/:realm/quest/:id' => sub {
    my $quest = db->quests->get(param('id'));
    my $comments = db->comments->list('quest', param('id'));

    $_->{updated} = $rfc3339->format_datetime(
        DateTime->from_epoch(epoch => $_->{ts})
    ) for $quest, @$comments;

    header 'Content-Type' => 'text/html';
    template 'seo/quest' => {
        quest => $quest,
        comments => $comments,
        markdown => \&markdown,
    };
};

get '/realm/:realm/quest/:id/comment/:cid' => sub {
    redirect "/realm/".param('realm')."/quest/".param('id');
};

get '/welcome' => sub {
    header 'Content-Type' => 'text/html';
    template 'seo/welcome' => {};
};

get '/realms' => sub {
    header 'Content-Type' => 'text/html';
    template 'seo/realms' => {};
};

1;
