define([
    'backbone'
], function (Backbone) {
    return Backbone.Model.extend({
        url: '/api/current_user/settings',
    });
});
