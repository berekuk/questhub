define(['backbone'],
function (Backbone) {
    return Backbone.Model.extend({
        idAttribute: '_id',
        name: function () {
            return this.get('action') + '-' + this.get('object_type');
        }
    });
});
