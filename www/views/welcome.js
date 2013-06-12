define([
    'underscore',
    'views/proto/common', 'views/user/signin',
    'views/realm/collection',
    'models/realm-collection',
    'models/current-user',
    'text!templates/welcome.html'
], function (_, Common, Signin, RealmCollection, RealmCollectionModel, currentUser, html) {
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
                return new RealmCollection({ collection: new RealmCollectionModel() });
            }
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
