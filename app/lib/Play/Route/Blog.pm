package Play::Route::Blog;

use Dancer ':syntax';
prefix '/blog';

get '/' => sub {
    template 'blog/front' => {}, { layout => 'blog' };
};

1;

