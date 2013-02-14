pp.views.QuestCollection = pp.View.AnyCollection.extend({

    t: 'quest-collection',

    generateItem: function (quest) {
        return new pp.views.QuestSmall({
            model: quest,
            showAuthor: this.options.showAuthor
        });
    },

    listSelector: '.quests-list',
});
