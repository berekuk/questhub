package Play;
use Dancer ':syntax';

use lib '/play/backend/lib';

use Play::Route::Users;
use Play::Route::Quests;
use Play::Route::Comments;
use Play::Route::Events;
use Play::Route::Dev;

hook after => sub {
    header 'Cache-Control' => 'max-age=0, private';
};

true;
