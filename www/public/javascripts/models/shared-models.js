define([
    'backbone',
    'models/realm-collection',
    'models/current-user'
], function (Backbone, RealmCollectionModel, currentUser) {
    var realms = new RealmCollectionModel();
    return {
        realms: realms,
        currentUser: currentUser
    };
});
