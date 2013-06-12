define([
    'backbone',
    'models/realm-collection'
], function (Backbone, RealmCollectionModel) {
    var realms = new RealmCollectionModel();
    return {
        realms: realms
    };
});
