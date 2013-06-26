define([
    'underscore',
    'views/proto/common',
    'views/realm/controls',
    'models/event-collection', 'views/event/collection',
    'text!templates/realm-page.html'
], function (_, Common, RealmControls, EventCollectionModel, EventCollection, html) {
    return Common.extend({
        template: _.template(html),

        activeMenuItem: 'realm-page',

        activated: false,

        subviews: {
            '.subview': 'eventCollection',
            '.realm-controls-subview': function () {
                return new RealmControls({ model: this.model });
            }
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
