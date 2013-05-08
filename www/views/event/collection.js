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

        listSelector: '.events-list',

        pageSize: 50,

        generateItem: function (model) {
            return new EventBox({ model: model });
        }
    });
});
