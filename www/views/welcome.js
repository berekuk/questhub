define([
    'underscore',
    'views/proto/common', 'views/user/signin',
    'models/current-user',
    'text!templates/welcome.html'
], function (_, Common, Signin, currentUser, html) {
    return Common.extend({
        template: _.template(html),
        selfRender: true,

        events: {
            'click .login-with-persona': 'personaLogin',
        },

        subviews: {
            '.signin': function () { return new Signin(); }
        },

        afterInitialize: function () {
            this.listenTo(currentUser, 'change:registered', function () {
                Backbone.trigger('pp:navigate', "/", { trigger: true, replace: true });
            });
        },

        personaLogin: function () {
            navigator.id.request();
        }
    });
});
