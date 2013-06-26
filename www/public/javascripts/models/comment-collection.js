define([
    'backbone', 'models/comment', 'models/current-user'
], function (Backbone, Comment, currentUser) {

    return Backbone.Collection.extend({
        initialize: function(models, args) {
            this.url = function() {
                var url = '/api/quest/' + args.quest_id + '/comment';
                return url;
            };
            this.quest_id = args.quest_id;
        },
        model: Comment,

        createTextComment: function (body, options) {
            // 'author', 'type' and 'ts' attributes will (hopefully) be ignored by server,
            // but we're going to use them for rendering
            return this.create({
                'author': currentUser.get('login'),
                'body': body,
                'quest_id': this.quest_id,
                'type': 'text',
                'ts': Math.floor(new Date().getTime() / 1000)
            }, options);
        }
    });
});
