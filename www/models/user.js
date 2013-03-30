define([
    'backbone'
], function (Backbone) {
    return Backbone.Model.extend({
        initialize: function() {
            alert("trying to instantiate abstract base class");
        }
    });
});
