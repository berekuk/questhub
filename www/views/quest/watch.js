define([
    'underscore',
    'views/proto/push-pull',
    'text!templates/quest-watch.html'
], function (_, PushPull, html) {
    return PushPull.extend({
        template: _.template(html),
        field: 'watchers',
        ownerField: 'user',

        push: function () {
            this.model.act('watch');
        },

        pull: function () {
            this.model.act('unwatch');
        }
    });
});
