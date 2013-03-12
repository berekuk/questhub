define([
    'views/proto/paged-collection',
    'views/user/small'
], function (PagedCollection, UserSmall) {
    return PagedCollection.extend({
        t: 'user-collection',
        listSelector: '.users-list',
        generateItem: function (model) {
            return new UserSmall({
                model: model
            });
        },
    });
});
