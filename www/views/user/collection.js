define([
    'underscore',
    'views/proto/paged-collection',
    'views/user/small',
    'text!templates/user-collection.html'
], function (_, PagedCollection, UserSmall, html) {
    return PagedCollection.extend({

        template: _.template(html),

        listSelector: '.users-list',

        generateItem: function (model) {
            return new UserSmall({
                model: model
            });
        },
    });
});
