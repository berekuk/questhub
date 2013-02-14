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
            that.$('.progress').show();
        }, 500);
    },

    noProgress: function () {
        this.$('.progress').hide();
        if (this.progressPromise) {
            window.clearTimeout(this.progressPromise);
        }
    },

    checkShowMoreButton: function () {
        if (this.userCount > this.collection.length) {
            this.$('.show-more').show();
        }
        else {
            this.$('.show-more').hide();
        }
    },

    updateUserCount: function () {

        this.progress();

        var that = this;

        $.get('/api/user_count')
        .done(function (data) {
            that.userCount = data.count;
            that.$('.progress').hide();
            that.noProgress.apply(that);
            that.checkShowMoreButton();
        })
        .fail(function (response) {
            pp.app.onError(false, response);
        });
    },

    afterInitialize: function () {
        pp.View.AnyCollection.prototype.afterInitialize.apply(this, arguments);
        this.progress(); // app.js fetches the collection for the first time immediately
        this.listenTo(this.collection, 'reset', this.updateUserCount); // update user count after the collection fetch
        this.listenTo(this.collection, 'error', this.noProgress);
        this.render();
    },

    showMore: function () {
        // FIXME: this is O(N^2).
        // Let's hope that Play Perl will grow popular enough that it'll need to be fixed.
        this.collection.fetchMore(50);
        this.$('.show-more').hide();
        this.progress();
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
