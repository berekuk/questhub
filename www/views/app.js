pp.views.App = Backbone.View.extend({

    template: _.template($('script#app').text()),

    initialize: function () {
    },

    render: function () {
        this.$el.html(this.template());
    }
});
