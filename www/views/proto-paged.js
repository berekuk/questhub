// collection which shows first N items, and then others can be fetched by clicking "show more" button
// your view is going to need:
// 1) template with a clickable '.show-more' element and with '.progress-spin' element
// 2) listSelector, just like in AnyCollection
// 3) generateItem, just like in AnyCollection
//
// This collection depends on pp.views.Progress, which depends on pp.View.Common... so it lives in a separate from proto.js file.
pp.View.PagedCollection = pp.View.AnyCollection.extend({
    events: {
        "click .show-more": "showMore",
    },

    subviews: {
        '.progress-spin': function () {
            return new pp.views.Progress();
        },
    },

    insertOne: function (el, options) {
        if (options && options.prepend) {
            this.$(this.listSelector).prepend(el);
        }
        else {
            this.$('.show-more').before(el);

        }
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

    afterRender: function () {
        pp.View.AnyCollection.prototype.afterRender.apply(this, arguments);
        this.$el.find('[data-toggle=tooltip]').tooltip('show');
    }

});
