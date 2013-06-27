define([
    'backbone',
    'views/proto/common',
    'views/user/signin',
    'models/current-user',
    'text!templates/user-unsubscribe.html'
], function (Backbone, Common, Signin, currentUser, html) {
    return Common.extend({
        template: _.template(html),

        selfRender: true,

        events: {
            'click .settings': function () {
                Backbone.trigger('pp:settings-dialog');
            }
        },

        subviews: {
            '.signin-subview': function () {
                return new Signin();
            }
        },

        serialize: function () {
            var params = this.options;
            params.current_user = currentUser.toJSON();
            return params;
        }
    });
});
