pp.views.EventBox = Backbone.View.extend({
    template: _.template($('#template-event-any').text()),

    initialize: function () {
        this.subview = new pp.views.Event({ model: this.model });
    },

    render: function () {
        this.$el.html(this.template(this.model.toJSON()));
        this.subview.setElement(this.$('.subview'));
        this.subview.render();

        this.$el.find("time.timeago").timeago();
    }
});
