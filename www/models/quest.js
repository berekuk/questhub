pp.models.Quest = Backbone.Model.extend({
    urlRoot: '/api/quest',
    close: function() {
        this.save(
            { "status": "closed" },
            { error: pp.app.onError }
        );
    },
    reopen: function() {
        this.save(
            { "status": "open" },
            { error: pp.app.onError }
        );
    }
});
