pp.views.UserCollection = Backbone.View.extend({

    template: _.template($('#template-user-collection').text()),

    events: {
        "click .show-switch": "switchAll",
    },

    initialize: function () {
        this.options.users.on('reset', this.render, this);
        this.all = true;
    },

    switchAll: function () {
        this.all = !this.all;
        this.render();
    },

    render: function () {
        var users = this.options.users;
        console.log('render ' + this.all);

        var that = this;
        users = users.filter(function(user) {
            if (that.all || user.get('open_quests') > 0) {
                return true;
            }
            return false;
        });

        this.$el.html(this.template({ users: users, all: this.all }));
        return this;
    }
});
