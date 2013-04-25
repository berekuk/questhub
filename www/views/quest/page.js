define([
    'underscore',
    'views/proto/common',
    'views/quest/big', 'views/comment/collection',
    'models/comment-collection',
    'models/current-user',
    'text!templates/quest-page.html'
], function (_, Common, QuestBig, CommentCollection, CommentCollectionModel, currentUser, html) {
    return Common.extend({

        activated: false,

        template: _.template(html),

        events: {
            'click .invite': 'inviteDialog',
            'click .uninvite': 'uninviteAction',
            'click .join': 'joinAction',
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
            var that = this;
            this.$('.invite-dialog').show(100, function () {
                console.log('focusing');
                that.$('.invite-dialog input').focus();
            });
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
            this.model.uninvite($(e.target).parent().attr('data-login'));
        },

        joinAction: function () {
            console.log('joinAction');
            this.model.join();
        },

        serialize: function () {
            var params = this.model.serialize();
            if (_.contains(params.invitee || [], currentUser.get('login'))) {
                params.invited = true;
            }
            else {
                params.invited = false;
            }
            return params;
        },

        afterInitialize: function () {
            this.listenTo(this.model, 'change', this.render);
        }
    });
});
