define([
    'backbone', 'settings'
], function (Backbone, settings) {
    return Backbone.Collection.extend({
        initialize: function () {
            this.reset(settings.realms);
        }
    });
});
