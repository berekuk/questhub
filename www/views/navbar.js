define([
    'views/proto/common',
    'models/current-user',
    'views/user/current',
    'text!templates/navbar.html'
], function (Common, currentUserModel, CurrentUser, html) {
    return Common.extend({
        template: _.template(html),

        serialize: function () {
            return {
                realm: this.getRealm(),
                partial: this.partial
            };
        },

        getRealm: function () {
            var view = this;
            var realm = _.find(
                this.partial.settings.realms,
                function (r) {
                    return r.id == view.options.realm;
                }
            );
            if (!realm) {
                throw "Oops";
            }
            return realm;
        },

        afterRender: function () {
            if (!this.currentUser) {
                this.currentUser = new CurrentUser({ model: currentUserModel });
                this.currentUser.setElement(this.$el.find('.current-user-box'));
            }
            else {
                this.currentUser.setElement(this.$el.find('.current-user-box')).render();
            }
        }
    });
});
