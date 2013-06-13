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
                types: this.options.types,
                'for': this.model.get('login')
            });
            collection.fetch();
            return new EventCollection({ collection: collection, showRealm: true });
        },

        events: function(){
            return _.extend({}, Common.prototype.events, {
                'click .filter' : 'filter'
            });
        },

        afterInitialize: function () {
            this.options.types = this.options.types || [];
            Common.prototype.afterInitialize.apply(this, arguments);
        },

        filter: function (e) {
            var pill = $(e.target).parent();

            var type = pill.attr('data-type');
            var types = this.options.types || [];
            if (pill.hasClass('active')) {
                // remove from types
                types = _.filter(types, function (t) {
                    return t != type;
                });
            }
            else {
                // add to types
                types.push(type);
                types = _.uniq(types);
            }
            pill.toggleClass('active');

            this.options.types = types;

            this.subview('.subview').collection.setTypes(types);

            /* Set queryString to URL */
            var url = '/';
            if ( types.length > 0 ) {
                url += '?types=' + types.join();
            }

            Backbone.trigger('pp:navigate', url, { replace: true });
        },

        serialize: function() {
            var filterList = [
                {
                    value: 'add-quest',
                    description: 'New quests'
                },
                {
                    value: 'close-quest',
                    description: 'Completed quests'
                },
                {
                    value: 'reopen-quest',
                    description: 'Reopened quests'
                },
                {
                    value: 'abandon-quest',
                    description: 'Abandoned quests'
                },
                {
                    value: 'resurrect-quest',
                    description: 'Resurrected quests'
                },
                {
                    value: 'add-user',
                    description: 'New players'
                },
                {
                    value: 'add-comment',
                    description: 'Comments'
                },
                {
                    value: 'invite-quest',
                    description: 'Invitations'
                }
            ];
            return {
                filterList: filterList,
                types: this.options.types,
                login: this.model.get('login'),
                tour: currentUser.onTour('feed'),
                followingRealms: currentUser.get('fr')
            };
        }
    });
});
