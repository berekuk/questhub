pp.views.UserCollection = pp.View.AnyCollection.extend({
    t: 'user-collection',

    events: {
        "click .show-more": "showMore",
    },

    listSelector: '.users-list',

    showMore: function () {
        // FIXME: this is O(N^2).
        // Let's hope that Play Perl will grow popular enough that it'll need to be fixed.
        this.collection.fetchMore(20);
    },

    generateItem: function (model) {
        return new pp.views.UserSmall({
            model: model
        });
    },

    afterRender: function () {
        console.log('afterRender');
        pp.View.AnyCollection.prototype.afterRender.apply(this, arguments);
        this.$el.find('[data-toggle=tooltip]').tooltip('show');
    }
});
