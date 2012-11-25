pp.views.QuestSmall = Backbone.View.extend({
    template: _.template($('#template-quest-small').text()),

    initialize: function () {
        var params = this.model.toJSON();
        this.setElement($(this.template(params)));
    }
});
