pp.models.CommentCollection = Backbone.Collection.extend({

    initialize: function(models, args) {
        this.url = function() {
            var url = '/api/comment/' + args.quest_id;
            return url;
        };
        this.quest_id = args.quest_id;
    },
    model: pp.models.Comment

});
