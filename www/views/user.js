pp.views.User = Backbone.View.extend({

    initialize: function () {
        this.model.on('change', this.render, this);
    },

    render: function () {
        this.$el.html(this.model.get('login'));
    }
});
