pp.views.CurrentUser = Backbone.View.extend({

    template: _.template($('script#template-current-user').text()),

    events: {
        'click .logout': 'logout'
    },

    initialize: function () {
        (this.model = new pp.models.User({current: true}))
            .on('change', this.render, this);

        this.model.fetch();
    },

    render: function () {
        this.$el.html(this.template(this.model.toJSON()));
    },

    logout: function () {
        $.ajax('/api/logout').always(function () {
            this.model.fetch();
        }.bind(this));
    }
});
