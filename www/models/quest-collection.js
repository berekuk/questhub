pp.models.QuestCollection = Backbone.Collection.extend({

    initialize: function(models, args) {
        this.url = function() {
            var url = '/api/quests';
            var cgi = [];
            if (args.user) {
                cgi.push('user=' + args.user);
            }
            if (args.user) {
                cgi.push('status=' + args.status);
            }
            if (cgi.length) {
                url += '?' + cgi.join('&');
            }
            return url;
        };
    },
    model: pp.models.Quest

});
