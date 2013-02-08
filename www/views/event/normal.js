pp.views.Event = Backbone.View.extend({
    template: function () {
        return _.template($('#template-event-' + this.model.get('action') + '-' + this.model.get('object_type')).text());
    },

    initialize: function () {
        console.log('event ' + this.model.id);
        var template = this.template();
        this.setElement($(template(this.model.toJSON())));
    }
});
