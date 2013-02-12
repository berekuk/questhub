pp.views.QuestPage = pp.View.Common.extend({
    t: 'quest-page',
    selfRender: true,

    subviews: {
        '.quest': function () {
            return new pp.views.QuestBig({
                model: this.model
            });
        },
        '.comments': function () {
            var commentsModel = new pp.models.CommentCollection([], { 'quest_id': this.model.id });
            commentsModel.fetch();
            return new pp.views.CommentCollection({
                collection: commentsModel
            });
        },
    },

    afterInitialize: function () {
        this.model.once('sync', function () {
            this.subview('.quest').activate();
        }, this);
        this.model.fetch();
    },

    afterRender: function () {
        // see http://stackoverflow.com/questions/6206471/re-render-tweet-button-via-js/6536108#6536108
        // $.ajax({ url: 'http://platform.twitter.com/widgets.js', dataType: 'script', cache:true});
    },
});
