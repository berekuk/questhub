package Play::Route::Blog;

use Dancer ':syntax';
prefix '/blog';

use File::Basename qw(basename);

use File::stat;
use DateTime::Format::RFC3339;

my $rfc3339 = DateTime::Format::RFC3339->new;

sub post_dir {
    "/play/app/blog";
}

sub load_post {
    my ($name) = @_;
    my $filename = post_dir."/$name";
    die "Not found" unless -e $filename;
    my $content = do {
        local (@ARGV, $/) = ($filename);
        <>
    };

    my ($header, $posted_header, $body) = split /\n/, $content, 3;
    my ($title) = $header =~ m{^<header>(.+)</header>$} or die "Failed to parse header '$header'";
    my ($posted_ts) = $posted_header =~ m{^<posted>(\d+)</posted>$} or die "Failed to parse header '$posted_header'";
    $name =~ s{\.html$}{};

    my $posted = $rfc3339->format_datetime(
        DateTime->from_epoch(epoch => $posted_ts)
    );

    return {
        title => $title,
        body => $body,
        name => $name,
        posted_ts => $posted_ts,
        posted => $posted,
        author => 'berekuk',
    };
}

sub load_all_posts {
    my @posts = map {
        load_post(basename($_))
    } glob post_dir()."/*";
    @posts = sort { $b->{posted_ts} <=> $a->{posted_ts} } @posts;
    return \@posts;
}

get '/' => sub {
    template 'blog/front' => {
        posts => load_all_posts()
    }, { layout => 'blog' };
};

get '/post/:name' => sub {
    template 'blog/post' => {
        post => load_post(param('name').".html")
    }, { layout => 'blog' };
};

get '/atom' => sub {
    header 'Content-Type' => 'application/xml';
    template 'blog/atom' => {
        posts => load_all_posts()
    };

};

1;
