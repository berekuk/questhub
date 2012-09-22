pp.views.CurrentUser = Backbone.View.extend({

    template: _.template($('script#template-current-user').text()),

    initialize: function () {
        (this.model = new pp.models.User({current: true}))
            .on('change', this.render, this);
        this.model.fetch();
    },

    render: function () {
        this.$el.html(this.template(this.model.toJSON()));
    }
});
