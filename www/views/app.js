pp.views.App = Backbone.View.extend({

    template: _.template($('script#template-app').text()),

    initialize: function () {
        this._currentUserView = new pp.views.CurrentUser();
        this.$el.html(this.template());
        this._currentUserView.setElement(this.$el.find('.current-user-box'));
    },

    setPageView: function (page) {
        if (this._page) {
            this._page.remove();
        }
        this._page = page;
        this.$el.find('.app-view-container').append((this._page = page).$el);
        page.render();
    }
});
