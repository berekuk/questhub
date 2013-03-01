pp.models.CommentCollection = Backbone.Collection.extend({

    initialize: function(models, args) {
        this.url = function() {
            var url = '/api/quest/' + args.quest_id + '/comment';
            return url;
        };
        this.quest_id = args.quest_id;
    },
    model: pp.models.Comment

});
