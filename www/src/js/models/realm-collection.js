define([
    'backbone', 'settings'
], function (Backbone, settings) {
    return Backbone.Collection.extend({
        url: '/api/realm'
    });
});
