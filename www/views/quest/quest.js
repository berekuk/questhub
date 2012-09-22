pp.views.Quest = Backbone.View.extend({
    template: _.template($('#template-quest').text()),

    initialize: function () {
        this.setElement($(this.template(this.model.toJSON())));
    }
});
