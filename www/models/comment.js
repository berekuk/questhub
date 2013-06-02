define([
    'backbone', 'jquery'
], function (Backbone, $) {
    return Backbone.Model.extend({
        idAttribute: '_id',

        urlRoot: function () {
            return '/api/quest/' + this.get('quest_id') + '/comment';
        },

        like: function() {
            this.act('like');
        },

        unlike: function() {
            this.act('unlike');
        },

        act: function(action) {
            var model = this;

            // FIXME - copypasted from models/quest.js
            // TODO - send only on success?
            ga('send', 'event', 'comment', action);
            mixpanel.track(action + ' comment');

            $.post(this.url() + '/' + action)
            .done(function () {
                model.fetch();
            });
        }
    });
});
