pp.views.App = Backbone.View.extend({

    initialize: function () {
        this._currentUserView = new pp.views.CurrentUser();
        this._currentUserView.setElement(this.$el.find('.current-user-box'));
    },

    userSettingsDialog: function () {
        this._currentUserView.settingsDialog();
    },

    setPageView: function (page) {
        if (this._page) {
            this._page.remove(); // TODO - should we remove all subviews too?
        }
        this._page = page;
        this.$el.find('.app-view-container').append(page.$el);

        // (THIS COMMENT IS DEPRECATED. EVERYTHING HAS CHANGED.)
        // we don't call page.render() - our pages render themselves, but sometimes they do it in delayed fashion
        // (i.e., wait for user model to fetch first, and sometimes navigate to the different page based on that)
    }
});
