pp.views.UserCollection = pp.View.PagedCollection.extend({
    t: 'user-collection',
    listSelector: '.users-list',
    generateItem: function (model) {
        return new pp.views.UserSmall({
            model: model
        });
    },
});
