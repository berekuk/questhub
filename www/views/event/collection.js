define([
    'jquery',
    'underscore',
    'views/proto/paged-collection',
    'views/event/box',
    'text!templates/event-collection.html',
    'bootstrap'
], function ($, _, PagedCollection, EventBox, html) {
    return PagedCollection.extend({
        template: _.template(html),

        tag: 'div',

        listSelector: '.events-list',

        generateItem: function (model) {
            return new EventBox({ model: model });
        },

        events: function(){
            return _.extend({},PagedCollection.prototype.events, {
                'click .filter' : 'filter'
            });
        },

        afterInitialize: function () {
            this.options.types = this.options.types || [];
            PagedCollection.prototype.afterInitialize.apply(this, arguments);
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

            this.collection.setTypes(types);

            /* Set queryString to URL */
            var url = '/feed';
            console.log(types);
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
                }
            ];
            return { filterList: filterList, types: this.options.types };
        }

    });
});
