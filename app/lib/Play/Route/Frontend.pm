package Play::Route::Frontend;

use Dancer ':syntax';

prefix '/';

get qr/.*/ => sub {
    send_file '/index.html';
};

true;
