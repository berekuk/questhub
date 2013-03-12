define([
    'views/proto/common'
], function (Common) {
    return Common.extend({
        t: 'signin',

        events: {
            'click .login-with-persona': 'loginWithPersona'
        },

        loginWithPersona: function () {
            navigator.id.request();
        }
    });
});
