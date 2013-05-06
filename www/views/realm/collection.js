define([
    'views/realm/normal',
    'views/proto/any-collection',
    'text!templates/realm-collection.html'
], function (Realm, AnyCollection, html) {
    return AnyCollection.extend({
        template: _.template(html),

        activated: true,

        generateItem: function(model) {
            return new Realm({ model: model });
        },

        listSelector: '.realms'
    });
});
