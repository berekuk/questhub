define([
    'underscore',
    'views/proto/any-collection',
    'views/proto/paged-collection',
    'views/quest/small',
    'text!templates/quest-collection.html'
], function (_, AnyCollection, PagedCollection, QuestSmall, html) {
    return PagedCollection.extend({
        template: _.template(html),

        listSelector: '.quests-list',
        generateItem: function (quest) {
            return new QuestSmall({
                model: quest,
                showAuthor: this.options.showAuthor,
                showStatus: this.options.showStatus
            });
        },

        // evil hack - ignore PagedCollection's afterRender, i.e. disable tooltip code
        afterRender: function () {
            AnyCollection.prototype.afterRender.apply(this, arguments);
        }
    });
});
