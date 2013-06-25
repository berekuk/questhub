define([
    'underscore',
    'views/proto/any-collection',
    'views/proto/paged-collection',
    'views/quest/small',
    'text!templates/quest-collection.html', 'jquery-ui'
], function (_, AnyCollection, PagedCollection, QuestSmall, html) {
    return PagedCollection.extend({
        template: _.template(html),

        listSelector: '.quests-list',
        generateItem: function (quest) {
            return new QuestSmall({
                model: quest,
                user: this.options.user,
                showStatus: this.options.showStatus,
                showRealm: this.options.showRealm
            });
        },

        // evil hack - ignore PagedCollection's afterRender, i.e. disable tooltip code
        afterRender: function () {
            if (this.options.sortable) {
                this.$('tbody').sortable().disableSelection();

                var that = this;
                this.$('tbody').on('sortupdate', function () {
                    var questIds = _.map(that.$('tr.quest-row td'), function (e) {
                        return e.getAttribute('data-quest-id');
                    });
                    that.collection.saveManualOrder(questIds);
                });
            }
            AnyCollection.prototype.afterRender.apply(this, arguments);
        }
    });
});
