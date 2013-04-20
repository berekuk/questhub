define([
    'views/like'
], function (Like) {
    return Like.extend({
        my: function (currentUser) {
            var team = this.model.get('team');
            team = team || [];
            return _.contains(team, currentUser.get('login'));
        }
    });
});
