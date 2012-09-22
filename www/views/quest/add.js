pp.views.QuestAdd = Backbone.View.extend({
    template: _.template($('#template-quest-add').text()),

    initialize: function () {
        this.setElement($(this.template()));
    }
});