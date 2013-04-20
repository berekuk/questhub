define([
    'underscore',
    'views/proto/push-pull',
    'text!templates/quest-watch.html'
], function (_, PushPull, html) {
    return PushPull.extend({
        template: _.template(html),
        field: 'watchers',

        my: function (currentUser) {
            var team = this.model.get('team');
            team = team || [];
            return _.contains(team, currentUser.get('login'));
        },

        push: function () {
            this.model.act('watch');
        },

        pull: function () {
            this.model.act('unwatch');
        }
    });
});
