pp.views.UserBig = Backbone.View.extend({
    // left column of the dashboard page

    template: _.template($('script#template-user-big').text()),

    initialize: function () {
        this.model.on('change', this.render, this);
    },

    render: function () {
        var params = this.model.toJSON();
        this.$el.html(this.template(params));
    },
});
