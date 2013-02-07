pp.views.CurrentUser = Backbone.View.extend({

    template: _.template($('script#template-current-user').text()),

    events: {
        'click .logout': 'logout'
    },

    initialize: function () {
        this.model = pp.app.user;

        this.model.on('change', this.render, this);

        this.model.fetch();
    },

    render: function () {
        this.$el.html(this.template(this.model.toJSON()));
    },

    logout: function () {
        // FIXME - it's probably better to reload the whole page
        $.post('/api/logout').always(function () {
            this.model.fetch();
            pp.app.router.navigate("/welcome", { trigger: true });
        }.bind(this));
    }
});
