pp.views.Event = pp.View.Base.extend({
    template: function () {
        return _.template($('#template-event-' + this.model.get('action') + '-' + this.model.get('object_type')).text());
    },

    render: function () {
        var template = this.template();
        var params = this.model.toJSON();
        params.partial = this.partial;
        this.$el.html(template(params));
        return this;
    }
});
