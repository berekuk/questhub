pp.views.UserCollection = pp.View.AnyCollection.extend({
    t: 'user-collection',

    events: {
        "click .show-more": "showMore",
    },

    listSelector: '.users-list',

    activated: true,

    progress: function () {
        this.noProgress();
        var that = this;
        this.progressPromise = window.setTimeout(function () {
            console.log('show spin');
            that.$('.icon-spinner').show();
        }, 500);
    },

    noProgress: function () {
        this.$('.show-more').toggle(this.collection.gotMore);
        this.$('.show-more').removeClass('disabled');
        this.$('.icon-spinner').hide();
        if (this.progressPromise) {
            window.clearTimeout(this.progressPromise);
        }
    },

    afterInitialize: function () {
        pp.View.AnyCollection.prototype.afterInitialize.apply(this, arguments);
        this.progress(); // app.js fetches the collection for the first time immediately
        this.collection.once('reset', this.noProgress, this);
        this.listenTo(this.collection, 'error', this.noProgress);
        this.render();
    },

    showMore: function () {
        var that = this;
        this.progress();
        this.$('.show-more').addClass('disabled');
        this.collection.fetchMore(3, {
            success: function (collection) {
                that.noProgress();
            },
            error: function (collection, response) {
                that.noProgress();
                pp.app.onError(undefined, response);
            }
        });
    },

    generateItem: function (model) {
        return new pp.views.UserSmall({
            model: model
        });
    },

    afterRender: function () {
        pp.View.AnyCollection.prototype.afterRender.apply(this, arguments);
        this.$el.find('[data-toggle=tooltip]').tooltip('show');
    }
});
