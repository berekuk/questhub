define([
    'backbone',
    'underscore', 'jquery',
    'views/proto/common',
    'views/quest/like',
    'views/comment/like',
    'models/quest',
    'models/comment',
    'text!templates/events.html'
], function (Backbone, _, $, Common, QuestLike, CommentLike, QuestModel, CommentModel, html) {

    var el = $(html);
    var eventViews = {};

    el.find('script').each(function () {
        var item = $(this);
        var name = item.attr('class');

        var view = Common.extend({
            template: _.template(item.text()),
            features: ['timeago']
        });
        eventViews[name] = view;

        // TODO - add 'close-quest' here too, after I fix the model sync issue
        // (if you like quest from one event, it doesn't affect the likes on the same quest in other event, since the model is not shared;
        // and then if you like another instance of this quest, you get error 500, because double liking is considered fatal (which is probably a mistake))
        if (name == 'add-quest') {
            view.prototype.subviews = {
                '.likes': function () {
                    var questModel = new QuestModel(this.model.get('quest'));
                    return new QuestLike({ model: questModel, hidden: true });
                }
            }
            view.prototype.events = {
                'mouseenter': function (e) {
                    this.subview('.likes').showButton();
                },
                'mouseleave': function (e) {
                    this.subview('.likes').hideButton();
                }
            };
        }
        else if (name == 'add-comment') {
            view.prototype.subviews = {
                '.likes': function () {
                    var commentModel = new CommentModel(this.model.get('comment'));
                    return new CommentLike({ model: commentModel });
                }
            }
            view.prototype.events = {
                'mouseenter': function (e) {
                    this.subview('.likes').showButton();
                },
                'mouseleave': function (e) {
                    this.subview('.likes').hideButton();
                }
            };
        }
    });

    return eventViews;
});
