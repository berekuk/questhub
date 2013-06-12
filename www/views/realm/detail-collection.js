define([
    'views/realm/big',
    'views/proto/any-collection',
    'text!templates/realm-detail-collection.html'
], function (RealmBig, AnyCollection, html) {
    return AnyCollection.extend({
        template: _.template(html),

        generateItem: function(model) {
            return new RealmBig({ model: model });
        },

        listSelector: '.realm-detail-collection',
        activeMenuItem: 'realms'
    });
});
