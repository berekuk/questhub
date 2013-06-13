define([
    'views/realm/small',
    'views/proto/any-collection',
    'text!templates/realm-collection.html'
], function (RealmSmall, AnyCollection, html) {
    return AnyCollection.extend({
        template: _.template(html),

        activated: true,

        generateItem: function(model) {
            return new RealmSmall({ model: model });
        },

        listSelector: '.realm-collection'
    });
});
