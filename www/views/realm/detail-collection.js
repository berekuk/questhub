define([
    'views/realm/big',
    'views/proto/any-collection',
    'models/current-user',
    'text!templates/realm-detail-collection.html'
], function (RealmBig, AnyCollection, currentUser, html) {
    return AnyCollection.extend({
        template: _.template(html),

        generateItem: function(model) {
            return new RealmBig({ model: model });
        },

        className: 'realm-detail-collection',

        listSelector: '.realm-detail-collection-list',
        activeMenuItem: 'realms',
        serialize: function () {
            console.log(currentUser);
            return {
                tour: currentUser.onTour('realms')
            }
        }
    });
});
