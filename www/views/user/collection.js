define([
    'underscore',
    'views/proto/paged-collection',
    'views/user/small',
    'text!templates/user-collection.html'
], function (_, PagedCollection, UserSmall, html) {
    return PagedCollection.extend({

        template: _.template(html),

        listSelector: '.users-list',

        realm: function () {
            return this.collection.options.realm;
        },

        generateItem: function (model) {
            return new UserSmall({
                model: model,
                realm: this.realm()
            });
        },
    });
});
