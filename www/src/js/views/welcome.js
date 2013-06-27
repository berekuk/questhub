define([
    'underscore',
    'views/proto/common', 'views/user/signin',
    'views/realm/collection',
    'models/current-user', 'models/shared-models',
    'text!templates/welcome.html'
], function (_, Common, Signin, RealmCollection, currentUser, sharedModels, html) {
    return Common.extend({
        template: _.template(html),
        selfRender: true,

        activeMenuItem: 'none',

        events: {
            'click .login-with-persona': 'personaLogin',
        },

        subviews: {
            '.signin': function () {
                return new Signin();
            },
            '.realms-subview': function () {
                var collection = sharedModels.realms;
                collection.fetch();
                return new RealmCollection({ collection: collection });
            }
        },

        afterInitialize: function () {
            this.listenTo(currentUser, 'change:registered', function () {
                Backbone.trigger('pp:navigate', "/", { trigger: true, replace: true });
            });
            mixpanel.track('visit /welcome');
        },

        personaLogin: function () {
            navigator.id.request();
        }
    });
});
