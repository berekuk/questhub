pp.models.Quest = Backbone.Model.extend({
    urlRoot: '/api/quest',

    close: function() {
        this._setStatus('closed');
    },

    reopen: function() {
        this._setStatus('open');
    },

    _setStatus: function(st) {
        this.save(
            { "status": st },
            {
                success: function () {
                    // quest status update causes update in points
                    pp.app.user.fetch();
                },
                error: pp.app.onError
            }
        );
    }

});
