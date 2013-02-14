pp.views.UserSmall = pp.View.Common.extend({
    t: 'user-small',

    tagName: 'tr',

    serialize: function () {
        var params = this.model.toJSON();
        params.currentUser = pp.app.user.get('login');
        return params;
    },

    afterRender: function () {
        var currentUser = pp.app.user.get('login');
        if (currentUser && this.model.get("login") == currentUser) {
            className = 'success';
        } else {
            className = 'warning';
        }
        this.$el.addClass(className);
    },
});
