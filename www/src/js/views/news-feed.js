define([
    'jquery',
    'underscore',
    'views/proto/common',
    'models/event-collection', 'views/event/collection',
    'models/current-user',
    'text!templates/news-feed.html',
    'bootstrap'
], function ($, _, Common, EventCollectionModel, EventCollection, currentUser, html) {
    return Common.extend({
        template: _.template(html),

        className: 'news-feed-view',

        activeMenuItem: 'feed',

        subviews: {
            '.subview': 'eventCollection',
        },

        eventCollection: function () {
            var collection = new EventCollectionModel([], {
                limit: 50,
                'for': this.model.get('login')
            });
            collection.fetch();
            return new EventCollection({ collection: collection, showRealm: true });
        },

        serialize: function() {
            return {
                login: this.model.get('login'),
                tour: currentUser.onTour('feed'),
                followingRealms: currentUser.get('fr')
            };
        }
    });
});
