define([], function () {
    if (window.location.host == 'play-perl.org') {
        window.location = 'http://questhub.io/perl' + window.location.pathname;
    }
    else if (window.location.host == 'frf-todo.berekuk.ru') {
        window.location = 'http://questhub.io/chaos' + window.location.pathname;
    }
    else if (window.location.host == 'questhub.io') {
        return {
            realms: [
                { id: 'chaos', name: 'Chaotic' },
                { id: 'perl', name: 'Perl' },
                { id: 'meta', name: 'Meta' }
            ],
            mixpanel_id: 'eb4a537d40eb92da515db8c18c415de4',
            analytics: 'UA-36251424-2'
        };
    }
    else {
        return {
            realms: [
                { id: 'chaos', name: 'Chaotic' },
                { id: 'perl', name: 'Perl' },
                { id: 'meta', name: 'Meta' }
            ],
            service_name: 'Questhub Dev',
            instance_name: 'dev',
            mixpanel_id: 'f3c2bc81bd754efae836aae54fb42a5a'
        }
    }
});
