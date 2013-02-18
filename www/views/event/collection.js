pp.views.EventCollection = pp.View.PagedCollection.extend({
    tag: 'div',

    t: 'event-collection',

    listSelector: '.events-list',

    generateItem: function (model) {
        return new pp.views.EventBox({ model: model });
    }
});
