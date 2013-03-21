define([
    'models/current-user',
    'views/proto/base',
    'views/notify', 'views/user/current',
    'text!templates/app.html'
], function (currentUserModel, Base, Notify, CurrentUser, html) {
    return Base.extend({

        template: _.template(html),

        initialize: function () {
            this.$el.html($(this.template({
                partial: this.partial
            }))); // render app just once
            document.title = this.partial.settings.service_name;

            this.currentUser = new CurrentUser({ model: currentUserModel });
            this.currentUser.setElement(this.$el.find('.current-user-box'));
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

            // the explanation of pattern can be found in this article: http://lostechies.com/derickbailey/2011/09/15/zombies-run-managing-page-transitions-in-backbone-apps/
            // (note that the article is dated - it's pre-0.9.2, Backbone didn't have .listenTo() back then
            if (this._page) {
                this._page.remove(); // TODO - should we remove all subviews too?
            }
            this._page = page;
            this.$('.app-view-container').append(page.$el);

            // (THIS COMMENT IS DEPRECATED. EVERYTHING HAS CHANGED.)
            // we don't call page.render() - our pages render themselves, but sometimes they do it in delayed fashion
            // (i.e., wait for user model to fetch first, and sometimes navigate to the different page based on that)
        },

        setActiveMenuItem: function (selector) {
            this.$el
                .find('.navbar .active')
                    .removeClass('active')
                    .end()
                .find('.menu-item-' + selector)
                    .addClass('active');
        }
    });
});
