define([
    'backbone'
], function (Backbone) {
    return Backbone.Model.extend({
        url: function () {
            return '/api/realm/' + this.get('id');
        }
    });
});
