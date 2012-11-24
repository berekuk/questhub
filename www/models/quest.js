pp.models.Quest = Backbone.Model.extend({
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
    }

});
