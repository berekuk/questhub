pp.views.Event = Backbone.View.extend({
    template: _.template($('#template-event').text()),

    initialize: function () {
        console.log('event ' + this.model.id);
        this.setElement($(this.template(this.model.toJSON())));
    }
});
