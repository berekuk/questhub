package Play;
use Dancer ':syntax';

use lib '/play/backend/lib';

use Play::Route::Users;
use Play::Route::Quests;
use Play::Route::Stencils;
use Play::Route::Comments;
use Play::Route::Events;
use Play::Route::Realms;
use Play::Route::Feeds;

use Play::Route::SEO;
use Play::Route::Blog;

use Play::Route::Dev;

hook after => sub {
    header 'Cache-Control' => 'max-age=0, private';
};

true;
