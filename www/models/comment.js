define([
    'backbone', 'jquery'
], function (Backbone, $) {
    return Backbone.Model.extend({
        idAttribute: '_id',

        like: function() {
            this.act('like');
        },

        unlike: function() {
            this.act('unlike');
        },

        act: function(action) {
            var model = this;
            $.post(this.url() + '/' + action)
            .done(function () {
                model.fetch();
            });
        }
    });
});
