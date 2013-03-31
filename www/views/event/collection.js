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

        events: {
            "click .filter": "filter"
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
            if ( filterString != undefined) {
                url += '?types=' + filterString;
            }

            Backbone.trigger('pp:navigate', url);

        },
        serialize: function() {
            var types = this.options.types || getParameterByName('types');
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
            for( var i = 0; i < filterList.length ; i++ ){
                if( types.indexOf(filterList[i].value) != -1 ){
                    filterList[i].status = 'checked';
                }else{
                    filterList[i].status = '';
                }
            }

            return { filterList: filterList };
        }

    });
});
