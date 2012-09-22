pp.views.App = Backbone.View.extend({

    template: _.template($('#template-app').text()),

    initialize: function () {},

    setPageView: function (page) {
        if (this._page) {
            this._page.remove();
        }
        this._page = page;
        this.$el.find('.app-view-container').append((this._page = page).$el);
        page.render();
    },

    render: function () {
        this.$el.html(this.template());
    }
});
