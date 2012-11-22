pp.views.Comment = Backbone.View.extend({
    template: _.template($('#template-comment').text()),

    initialize: function () {
        this.setElement($(this.template(this.model.toJSON())));
    }
});
