pp.views.QuestSmall = Backbone.View.extend({
    template: _.template($('#template-quest-small').text()),

    initialize: function () {
        var params = this.model.toJSON();
        console.log(params);
        this.setElement($(this.template(params)));
    }
});
