pp.views.QuestCollection = Backbone.View.extend({

    tag: 'div',

    template: _.template($('#template-quest-collection').text()),

    initialize: function () {
        this.setElement(
            $(this.template({
                quests: this.options.collection.models
            }))
        );
    }
});
