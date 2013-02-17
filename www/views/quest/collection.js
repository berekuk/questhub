pp.views.QuestCollection = pp.View.AnyCollection.extend({
    t: 'quest-collection',

    events: {
        "click .show-more": "showMore",
    },

    subviews: {
        '.progress-spin': function () {
            return new pp.views.Progress();
        },
    },

    listSelector: '.quests-list',
    insertOne: function (el) {
        this.$('.show-more').before(el);
    },

    activated: true,

    pageSize: 100,

    noProgress: function () {
        this.$('.show-more').toggle(this.collection.gotMore);
        this.$('.show-more').removeClass('disabled');
        this.subview('.progress-spin').off();
    },

    afterInitialize: function () {
        pp.View.AnyCollection.prototype.afterInitialize.apply(this, arguments);
        this.subview('.progress-spin').on(); // app.js fetches the collection for the first time immediately

        this.collection.once('reset', this.noProgress, this);
        this.listenTo(this.collection, 'error', this.noProgress);
        this.render();
    },

    showMore: function () {
        var that = this;

        this.$('.show-more').addClass('disabled');
        this.subview('.progress-spin').on();

        this.collection.fetchMore(this.pageSize, {
            error: function (collection, response) {
                pp.app.onError(undefined, response);
            }
        }).always(function () {
            that.noProgress();
        });
    },

    generateItem: function (quest) {
        return new pp.views.QuestSmall({
            model: quest,
            showAuthor: this.options.showAuthor
        });
    },
});
