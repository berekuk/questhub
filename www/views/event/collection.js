define([
    'underscore',
    'views/proto/paged-collection',
    'views/event/box',
    'text!templates/event-collection.html'
], function (_, PagedCollection, EventBox, html) {
    return PagedCollection.extend({
        template: _.template(html),

        tag: 'div',

        listSelector: '.events-list',

        generateItem: function (model) {
            return new EventBox({ model: model });
        },

        events: function(){
            return _.extend({},PagedCollection.prototype.events,{
                'click .filter' : 'filter'
            });
        },

        filter: function () {
            var types=[];
            $('.filter:checked').each(function() {
                types.push($(this).val());
            });

            var filterString = types.join();

            this.options.types = types;

            this.collection.setTypes(types);

            /* Set queryString to URL */
            var url = '/feed';
            if ( types.length > 0 ) {
                url += '?types=' + filterString;
            }

            Backbone.trigger('pp:navigate', url, { replace: true });

        },
        serialize: function() {
            var types = this.options.types || [];

            var filterList = [
                {
                    value: 'add-comment',
                    description: 'add-comment',
                },
                {
                    value: 'add-quest',
                    description: 'add-quest',
                }
            ]

            /* Add status for each filter */
            _.each( filterList, function(list){
                if( types.indexOf(list.value) != -1 ){
                    list.status = 'checked';
                }else{
                    list.status = '';
                }
            });

            return { filterList: filterList };
        }

    });
});
