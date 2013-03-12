define([
    'views/proto/paged-collection',
    'views/event/box'
], function (PagedCollection, EventBox) {
    return PagedCollection.extend({
        tag: 'div',

        t: 'event-collection',

        listSelector: '.events-list',

        generateItem: function (model) {
            return new EventBox({ model: model });
        }
    });
});
