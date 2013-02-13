pp.views.UserCollection = pp.View.Base.extend({

    template: _.template($('#template-user-collection').text()),

    events: {
        "click .show-switch": "switchAll",
    },

    initialize: function () {
        this.collection.on('reset', this.render, this);
        this.all = false;
    },

    switchAll: function () {
        this.all = !this.all;
        this.render();
    },

    render: function () {

        var that = this;
        var users = this.collection.filter(function(user) {
            if (that.all || user.get('open_quests') > 0 || user.get('points') > 0) {
                return true;
            }
            return false;
        });

        this.$el.html(this.template({
            users: users,
            all: this.all,
            partial: this.partial,
            currentUser: pp.app.user.get('login') // used for highlighting
        }));
        that.$el.find('[data-toggle=tooltip]').tooltip('show');
        return this;
    }
});
