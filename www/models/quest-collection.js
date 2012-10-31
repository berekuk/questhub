pp.models.QuestCollection = Backbone.Collection.extend({

    initialize: function(models, args) {
        this.url = function() {
            var url = '/api/quests';
            if (args.user) {
                url += '?user=' + args.user;
            }
            return url;
        };
    },
    model: pp.models.Quest

});
