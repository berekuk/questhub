define([], function () {
    if (window.location.host == 'play-perl.org') {
        return {
            service_name: 'Play Perl',
            instance_name: 'play-perl'
        };
    }
    else if (window.location.host == 'frf-todo.berekuk.ru') {
        window.location = 'http://questhub.io' + window.location.pathname;
    }
    else {
        return {
            service_name: 'Questhub.io',
            instance_name: 'questhub'
        };
    }
});
