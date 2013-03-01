pp.views.QuestLike = pp.View.Common.extend({
    t: 'quest-like',

    events: {
        "click .quest-like": "like",
        "click .quest-unlike": "unlike",
    },

    afterInitialize: function () {
        if (this.options.showButton == undefined) {
            this._sb = true;
        }
        else {
            this._sb = this.options.showButton;
        }
        this.listenTo(this.model, 'change', this.render);
    },

    showButton: function () {
        this.$('.like-button').show();
        this._sb = true;
    },

    hideButton: function () {
        this.$('.like-button').hide();
        this._sb = false;
    },

    like: function () {
        this.model.like();
    },

    unlike: function () {
        this.model.unlike();
    },

    serialize: function () {
        var likes = this.model.get('likes');
        var my = (pp.app.user.get('login') == this.model.get('user'));
        var currentUser = pp.app.user.get('login');
        var meGusta = _.contains(likes, currentUser);

        var params = {
            likes: this.model.get('likes'),
            my: (pp.app.user.get('login') == this.model.get('user')),
            currentUser: pp.app.user.get('login'),
        };
        params.meGusta = _.contains(params.likes, params.currentUser);
        return params;
    },

    afterRender: function () {
        if (this._sb) {
            this.showButton();
        }
    },

    features: ['tooltip'],
});
