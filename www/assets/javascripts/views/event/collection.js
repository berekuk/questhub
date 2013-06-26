define([
    'jquery',
    'underscore',
    'views/proto/any-collection',
    'views/proto/paged-collection',
    'views/event/box',
    'text!templates/event-collection.html'
], function ($, _, AnyCollection, PagedCollection, EventBox, html) {
    return PagedCollection.extend({
        template: _.template(html),

        listSelector: '.event-collection',

        pageSize: 50,

        afterInitialize: function () {
            PagedCollection.prototype.afterInitialize.apply(this, arguments);
            this.listenTo(Backbone, 'pp:quest-add', function (model) {
                this.collection.fetch();
            });
        },

        generateItem: function (model) {
            return new EventBox({ model: model, showRealm: this.options.showRealm });
        }
    });
});
