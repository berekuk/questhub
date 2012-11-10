pp.views.UserCollection = Backbone.View.extend({

    tag: 'div',

    template: _.template($('#template-user-collection').text()),

    initialize: function () {
        this.options.users.on('reset', this.render, this);
    },

    render: function (collection) {
        this.$el.html(this.template({ users: this.options.users }));
        return this;
    }
});
