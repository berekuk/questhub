pp.views.QuestSmall = Backbone.View.extend({
    template: _.template($('#template-quest-small').text()),

    initialize: function () {
        this.setElement($(this.template(this.model.toJSON())));
    }
});
