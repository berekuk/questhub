define([
    'underscore',
    'views/proto/common',
    'views/quest/big', 'views/comment/collection',
    'models/comment-collection',
    'text!templates/quest-page.html'
], function (_, Common, QuestBig, CommentCollection, CommentCollectionModel, html) {
    return Common.extend({

        activated: false,

        template: _.template(html),

        events: {
            'click button.invite': 'inviteDialog',
            'click .uninvite': 'uninviteAction',
            'keyup [name=invitee]': 'inviteAction'
        },

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

        inviteDialog: function () {
            this.$('.invite-dialog').show();
        },

        inviteAction: function (e) {
            if (e.keyCode != 13) {
                return;
            }
            this.model.invite(
                this.$('[name=invitee]').val()
            );
        },

        uninviteAction: function (e) {
            console.log(e.target);
            this.model.uninvite($(e.target).parent().attr('data-login'));
        },

        serialize: function () {
            return this.model.serialize();
        },

        afterInitialize: function () {
            this.listenTo(this.model, 'change', this.render);
        }
    });
});
