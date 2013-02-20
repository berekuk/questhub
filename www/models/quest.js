pp.models.Quest = Backbone.Model.extend({
    idAttribute: '_id',
    urlRoot: '/api/quest',

    like: function() {
        this._likeOrUnlike('like');
    },

    unlike: function() {
        this._likeOrUnlike('unlike');
    },

    close: function() {
        this._setStatus('closed');
    },

    abandon: function() {
        this._setStatus('abandoned');
    },

    resurrect: function() {
        this._setStatus('open');
    },

    reopen: function() {
        this._setStatus('open');
    },

    _setStatus: function(st) {
        var model = this.model;
        this.save(
            { "status": st },
            {
                success: function (model) {
                    if (model.get('user') == pp.app.user.get('login')) {
                        // update of the current user's quest causes update in points
                        pp.app.user.fetch();
                    }
                },
                error: pp.app.onError
            }
        );
    },

    _likeOrUnlike: function(action) {
        var model = this;
        $.post(this.url() + '/' + action)
            .success(function () {
                model.fetch();
            }); // TODO - error handling?
    },

    comment_count: function () {
        return this.get('comment_count') || 0;
    },

    like_count: function () {
        var likes = this.get('likes');
        if (likes) {
            return likes.length;
        }
        return 0;
    }

});
