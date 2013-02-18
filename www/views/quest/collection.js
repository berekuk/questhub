pp.views.QuestCollection = pp.View.PagedCollection.extend({
    t: 'quest-collection',

    listSelector: '.quests-list',
    generateItem: function (quest) {
        return new pp.views.QuestSmall({
            model: quest,
            showAuthor: this.options.showAuthor
        });
    },

    // evil hack - ignore PagedCollection's afterRender, i.e. disable tooltip code
    afterRender: function () {
        pp.View.AnyCollection.prototype.afterRender.apply(this, arguments);
    }
});
