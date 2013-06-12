define([
    'underscore',
    'views/proto/common',
    'models/event-collection', 'views/event/collection',
    'text!templates/realm-page.html'
], function (_, Common, EventCollectionModel, EventCollection, html) {
    return Common.extend({
        template: _.template(html),

        activeMenuItem: 'realm-page',

        activated: false,

        subviews: {
            '.subview': 'eventCollection',
        },

        realm: function () {
            return this.model.get('id');
        },

        eventCollection: function () {
            var collection = new EventCollectionModel([], {
                limit: 50,
                realm: this.realm()
            });
            collection.fetch();
            return new EventCollection({ collection: collection });
        }
    });
});
