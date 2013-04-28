define([], function () {
    if (window.location.host == 'play-perl.org') {
        return {
            service_name: 'Play Perl',
            instance_name: 'play-perl',
            mixpanel_id: 'de59dd3d112a831233d05a19354b2ba3'
        };
    }
    else if (window.location.host == 'frf-todo.berekuk.ru') {
        window.location = 'http://questhub.io' + window.location.pathname;
    }
    else if (window.location.host == 'questhub.io') {
        return {
            service_name: 'Questhub.io',
            instance_name: 'questhub',
            mixpanel_id: 'eb4a537d40eb92da515db8c18c415de4'
        };
    }
    else {
        return {
            service_name: 'Questhub Dev',
            instance_name: 'dev',
            mixpanel_id: 'f3c2bc81bd754efae836aae54fb42a5a'
        }
    }
});
