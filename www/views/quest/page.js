pp.views.QuestPage = Backbone.View.extend({
    template: _.template($('#template-quest-page').text()),

    initialize: function () {
        this.render();
    },

    render: function () {
        this.$el.html(this.template());

        var details = new pp.views.QuestBig({ model: this.model });
        this.$el.find('.quest').append(details.$el);

        var commentsModel = new pp.models.CommentCollection([], { 'quest_id': this.model.id });
        commentsModel.fetch();
        this.comments = new pp.views.CommentCollection({
            comments: commentsModel
        });
        this.$el.find('.comments').append(this.comments.$el);

        // see http://stackoverflow.com/questions/6206471/re-render-tweet-button-via-js/6536108#6536108
        $.ajax({ url: 'http://platform.twitter.com/widgets.js', dataType: 'script', cache:true});
    },
});
