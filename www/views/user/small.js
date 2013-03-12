define([
    'views/proto/common',
    'models/current-user'
], function (Common, currentUser) {
    return Common.extend({
        t: 'user-small',

        tagName: 'tr',

        serialize: function () {
            var params = this.model.toJSON();
            params.currentUser = currentUser.get('login');
            return params;
        },

        afterRender: function () {
            var currentLogin = currentUser.get('login');
            if (currentLogin && this.model.get("login") == currentLogin) {
                className = 'success';
            } else {
                className = 'warning';
            }
            this.$el.addClass(className);
        },
    });
});
