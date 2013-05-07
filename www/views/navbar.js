define([
    'backbone',
    'views/proto/common',
    'models/current-user',
    'views/user/current',
    'text!templates/navbar.html'
], function (Backbone, Common, currentUserModel, CurrentUser, html) {
    return Common.extend({
        template: _.template(html),

        serialize: function () {
            var params = {
                realm: this.getRealm(),
                partial: this.partial,
                registered: currentUserModel.get('registered')
            };
            if (this.options.realm) {
                params.url = Backbone.history.getFragment();
                params.url = params.url.replace(/^\w+\//, '');
            }
            else {
                params.url = 'feed';
            }
            return params;
        },

        getRealm: function () {
            var view = this;
            if (!view.options.realm) {
                return;
            }

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

            if (this.active) {
                this.$el
                    .find('.menu-item-' + this.active)
                    .addClass('active');
            }
        },

        setActiveMenuItem: function (selector) {
            this.active = selector;
            this.render();
        }
    });
});
