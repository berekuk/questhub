pp.views.UserCollection = pp.View.AnyCollection.extend({
    t: 'user-collection',

    events: {
        "click .show-switch": "switchAll",
    },

    listSelector: '.users-list',

    all: false,

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
        this.collection.reset(users, { silent: true });
        pp.View.AnyCollection.prototype.render.apply(this, arguments);
    },

    generateItem: function (model) {
        return new pp.views.UserSmall({
            model: model
        });
    },

    afterRender: function () {
        pp.View.AnyCollection.prototype.afterRender.apply(this, arguments);
        this.$el.find('[data-toggle=tooltip]').tooltip('show');
    }
});
