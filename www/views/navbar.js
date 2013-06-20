define([
    'backbone',
    'views/proto/common',
    'models/current-user', 'models/shared-models',
    'views/user/current',
    'views/quest/add',
    'text!templates/navbar.html'
], function (Backbone, Common, currentUserModel, sharedModels, CurrentUser, QuestAdd, html) {
    return Common.extend({
        template: _.template(html),

        events: {
            'click .quest-add-nav-button': function () {
                return new QuestAdd({
                    realm: this.options.realm
                });
            }
        },

        afterInitialize: function () {
            this.listenTo(Backbone, 'pp:quiet-url-update', function () {
                this.render();
            });
        },

        serialize: function () {
            var params = {
                realm: this.getRealm(),
                partial: this.partial,
                registered: currentUserModel.get('registered'),
                currentUser: currentUserModel.get('login')
            };
            return params;
        },

        getRealm: function () {
            if (!this.options.realm) {
                return;
            }

            var realm = sharedModels.realms.findWhere({ id: this.options.realm });
            if (!realm) {
                throw "Oops";
            }
            return realm.toJSON();
        },

        render: function () {
            // wait for realms data; copy-paste from views/quest/add
            if (!sharedModels.realms.length) {
                var that = this;
                sharedModels.realms.fetch()
                .success(function () {
                    that.render();
                });
                return;
            }

            Common.prototype.render.apply(this, arguments);
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

        setActive: function (selector) {
            this.active = selector; // don't render - views/app will call render() itself soon
        }
    });
});
