define([
    'underscore',
    'views/proto/common',
    'views/quest/big', 'views/comment/collection',
    'models/comment-collection',
    'text!templates/quest-page.html'
], function (_, Common, QuestBig, CommentCollection, CommentCollectionModel, html) {
    return Common.extend({
        template: _.template(html),

        selfRender: true,

        subviews: {
            '.quest-big': function () {
                return new QuestBig({
                    model: this.model
                });
            },
            '.comments': function () {
                var commentsModel = new CommentCollectionModel([], { 'quest_id': this.model.id });
                commentsModel.fetch();
                return new CommentCollection({
                    collection: commentsModel
                });
            },
        },

        afterInitialize: function () {
            this.model.once('sync', function () {
                this.subview('.quest-big').activate();
            }, this);
            this.model.fetch();
        },

        afterRender: function () {
            // see http://stackoverflow.com/questions/6206471/re-render-tweet-button-via-js/6536108#6536108
            // $.ajax({ url: 'http://platform.twitter.com/widgets.js', dataType: 'script', cache:true});
        },
    });
});
