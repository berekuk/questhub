pp.views.Event = Backbone.View.extend({
    template: function () {
        return _.template($('#template-event-' + this.model.get('action') + '-' + this.model.get('object_type')).text());
    },

    render: function () {
        var template = this.template();
        this.$el.html(template(this.model.toJSON()));
    }
});
