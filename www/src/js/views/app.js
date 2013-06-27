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

        notify: function (type, message) {
            this.$('.app-view-notifies').html('');
            this.$('.app-view-notifies').append(
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


            var menuItem = _.result(page, 'activeMenuItem') || 'none';
            this.subview('.navbar-subview').setActive(menuItem);

            // FIXME - this leads to double-rendering navbar on the initial page load
            this.updateRealm();
        },

        updateRealm: function () {
            var realm = (this._page.realm ? this._page.realm() : null);

            this.realm_id = realm;
            this.subview('.navbar-subview').options.realm = this.realm_id;
            this.subview('.navbar-subview').render();
        },

        settingsDialog: function () {
            this.subview('.navbar-subview').currentUser.settingsDialog();
        }
    });
});
