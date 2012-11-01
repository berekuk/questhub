pp.models.Quest = Backbone.Model.extend({
    urlRoot: '/api/quest',
    close: function() {
        this.save(
            { "status": "closed" },
            { error: pp.app.onError }
        );
    },
});
