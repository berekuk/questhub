define([
    'backbone',
    'underscore', 'jquery',
    'views/proto/common',
    'views/quest/like',
    'views/comment/like',
    'models/quest',
    'models/comment',
    'text!templates/event.html'
], function (Backbone, _, $, Common, QuestLike, CommentLike, QuestModel, CommentModel, html) {
    return Common.extend({
        template: _.template(html),
        features: ['timeago'],

        // TODO - add 'close-quest' here too, after I fix the model sync issue
        // (if you like quest from one event, it doesn't affect the likes on the same quest in other event, since the model is not shared;
        // and then if you like another instance of this quest, you get error 500, because double liking is considered fatal (which is probably a mistake))
        likeable: ['add-quest', 'add-comment'],

        events: function () {
            if (_.contains(this.likeable, this.model.name())) {
                return {
                    'mouseenter': function (e) {
                        this.subview('.likes').showButton();
                    },
                    'mouseleave': function (e) {
                        this.subview('.likes').hideButton();
                    }
                }
            }
            else {
                return {};
            }
        },

        subviews: function () {
            if (this.model.name() == 'add-quest') {
                return {
                    '.likes': function () {
                        var questModel = new QuestModel(this.model.get('quest'));
                        return new QuestLike({ model: questModel, hidden: true });
                    }
                }
            }
            else if (this.model.name() == 'add-comment') {
                return {
                    '.likes': function () {
                        var commentModel = new CommentModel(this.model.get('comment'));
                        return new CommentLike({ model: commentModel });
                    }
                }
            }
            else {
                return {};
            }
        }
    });
});
