pp.views.QuestShow = Backbone.View.extend({
    template: _.template($('#template-quest-show').text()),

    events: {
        "click .quest-close": "close",
        "click .quest-reopen": "reopen"
    },

    close: function () {
        this.model.close();
    },

    reopen: function () {
        this.model.reopen();
    },

    initialize: function () {
        // FIXME - fix double rendering
        this.model.bind('change', this.render, this);
        pp.app.user.bind('change', this.render, this);

        this.model.fetch();
    },

    render: function () {
        var params = this.model.toJSON();
        // TODO - should we move this to model?
        params.my = (pp.app.user.get('login') == params.user);

        var commentsModel = new pp.models.CommentCollection([], { 'quest_id': this.model.id });
        commentsModel.fetch();
        this.comments = new pp.views.CommentCollection({
            comments: commentsModel
        });

        this.$el.html(this.template(params));
        this.$el.find('.comments').append(this.comments.$el);

        // see http://stackoverflow.com/questions/6206471/re-render-tweet-button-via-js/6536108#6536108
        $.ajax({ url: 'http://platform.twitter.com/widgets.js', dataType: 'script', cache:true});
    },
});
