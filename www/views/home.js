define([
    'views/proto/common',
    'views/user/signin',
    'models/current-user'
], function (Common, Signin, currentUser) {
    return Common.extend({
        t: 'home',
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
