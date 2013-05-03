define([
    'underscore',
    'views/proto/common',
    'views/notify', 'views/navbar',
    'text!templates/app.html'
], function (_, Common, Notify, Navbar, html) {
    return Common.extend({

        template: _.template(html),

        realm_id: null,

        subviews: {
            '.navbar-subview': function () {
                return new Navbar({
                    realm: this.realm_id
                });
            }
        },

        afterInitialize: function () {
            // configure tracking
            mixpanel.init(this.partial.settings.mixpanel_id, {
                'track_pageview': false
            });
            if (this.partial.settings.analytics) {  // TODO - configure localhost for debugging?
                ga('create', this.partial.settings.analytics, window.location.host);
            }
        },

        afterRender: function () {
            document.title = this.partial.settings.service_name;
        },

        notify: function (type, message) {
            this.$('.app-view-container').prepend(
                new Notify({
                    type: type,
                    message: message
                }).render().el
            );
        },

        setPageView: function (page) {
            // the explanation of this pattern can be found in this article: http://lostechies.com/derickbailey/2011/09/15/zombies-run-managing-page-transitions-in-backbone-apps/
            // (note that the article is dated - it's pre-0.9.2, Backbone didn't have .listenTo() back then
            if (this._page) {
                this._page.remove(); // TODO - should we remove all subviews too?
            }
            this._page = page;
            this.$('.app-view-container').append(page.$el);

            // FIXME - this leads to double-rendering navbar on the initial page load
            if (page.realm) {
                this.setRealm(page.realm());
            }
            else {
                this.setRealm(null);
            }
        },

        setRealm: function (realm) {
            if (this.realm_id == realm) {
                return;
            }
            this.realm_id = realm;
            this.subview('.navbar-subview').options.realm = this.realm_id;
            this.subview('.navbar-subview').render();
        },

        // FIXME - this should probably be an event
        setActiveMenuItem: function (selector) {
            this.$el
                .find('.navbar .active')
                    .removeClass('active')
                    .end()
                .find('.menu-item-' + selector)
                    .addClass('active');
        },

        settingsDialog: function () {
            this.subview('.navbar-subview').currentUser.settingsDialog();
        }
    });
});
