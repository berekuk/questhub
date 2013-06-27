define([
    'underscore',
    'views/proto/common',
    'text!templates/signin.html'
], function (_, Common, html) {
    return Common.extend({
        template: _.template(html),

        events: {
            'click .login-with-persona': 'loginWithPersona'
        },

        loginWithPersona: function () {
            navigator.id.request();
        }
    });
});
