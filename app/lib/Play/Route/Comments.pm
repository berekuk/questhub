package Play::Route::Comments;

use Dancer ':syntax';
prefix '/api';

use Play::DB qw(db);
use Play::App::Util qw(login);

for my $entity (qw( quest stencil )) {
    post "/$entity/:eid/comment" => sub {
        my $login = login;

        return db->comments->add({
            entity => $entity,
            eid => param('eid'),
            body => param('body'),
            author => $login,
        });
    };

    get "/$entity/:eid/comment" => sub {
        return db->comments->list($entity, param('eid'));
    };

    get "/$entity/:eid/comment/:id" => sub {
        return db->comments->get_one(param('id'));
    };

    del "/$entity/:eid/comment/:id" => sub {
        my $login = login;
        db->comments->remove({
            id => param('id'),
            user => $login,
        });
        return {
            result => 'ok',
        }
    };

    put "/$entity/:eid/comment/:id" => sub {
        my $login = login;
        my $updated_id = db->comments->update({
            id => param('id'),
            body => param('body'),
            user => $login
        });
        return {
            _id => $updated_id,
        }
    };

    for my $method (qw/ like unlike /) {
        post "/$entity/:eid/comment/:id/$method" => sub {
            my $login = login;
            db->comments->$method(param('id'), $login);

            return {
                result => 'ok',
            }
        };
    }
}

true;
