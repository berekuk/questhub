pp.views.CurrentUser = pp.View.Common.extend({

    t: 'current-user',

    events: {
        'click .logout': 'logout'
    },

    afterInitialize: function () {
        this.model = pp.app.user;
        this.model.on('change', this.render, this);
        this.model.fetch();
    },

    logout: function () {
        // FIXME - it's probably better to reload the whole page
        $.post('/api/logout').always(function () {
            this.model.fetch();
            pp.app.router.navigate("/welcome", { trigger: true });
        }.bind(this));
    }
});
