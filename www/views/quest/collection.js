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

        saveManualOrder: function () {
            if (this.ordering) {
                this.moreOrdering = true;
                return;
            }
            var questIds = _.map(this.$('tr.quest-row td'), function (e) {
                return e.getAttribute('data-quest-id');
            });
            var deferred = this.collection.saveManualOrder(questIds);

            this.ordering = true;
            this.trigger('save-order');

            var that = this;
            deferred.always(function () {
                that.ordering = false;
                if (that.moreOrdering) {
                    that.moreOrdering = false;
                    that.saveManualOrder();
                }
                else {
                    that.moreOrdering = false;
                    that.trigger('order-saved');
                }
            });
        },

        afterRender: function () {
            if (this.options.sortable) {
                this.$('tbody').sortable({
                    helper: function (e, ui) {
                        ui.children().each(function() {
                            $(this).width($(this).width());
                        });
                        return ui;
                    }
                }).disableSelection();
                var that = this;
                this.$('tbody').on('sortupdate', function () {
                    that.saveManualOrder();
                });
            }

            PagedCollection.prototype.afterRender.apply(this, arguments);
        }
    });
});
