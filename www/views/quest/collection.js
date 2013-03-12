define([
    'views/proto/any-collection',
    'views/proto/paged-collection',
    'views/quest/small'
], function (AnyCollection, PagedCollection, QuestSmall) {
    return PagedCollection.extend({
        t: 'quest-collection',

        listSelector: '.quests-list',
        generateItem: function (quest) {
            return new QuestSmall({
                model: quest,
                showAuthor: this.options.showAuthor
            });
        },

        // evil hack - ignore PagedCollection's afterRender, i.e. disable tooltip code
        afterRender: function () {
            AnyCollection.prototype.afterRender.apply(this, arguments);
        }
    });
});
