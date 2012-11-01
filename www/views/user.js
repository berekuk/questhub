pp.views.User = Backbone.View.extend({

    template: _.template($('script#template-user').text()),

    initialize: function () {
        this.model.on('change', this.render, this);
    },

    render: function () {
        this.$el.html(this.template(this.model.toJSON()));
    }
});
