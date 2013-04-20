define([
    'views/like'
], function (Like) {
    return Like.extend({
        hidden: true,
        my: function (currentUser) {
            return this.model.get('author') == currentUser.get('login');
        }
    });
});
