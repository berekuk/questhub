define([
    'underscore',
    'views/realm/pick',
    'views/proto/any-collection',
    'text!templates/realm-collection.html'
], function (_, RealmPick, AnyCollection, html) {
    return AnyCollection.extend({
        template: _.template(html),

        activated: true,

        generateItem: function(model) {
            var item = new RealmPick({ model: model, picker: this });
            this.listenTo(item, 'pick', function () {
                this.trigger('pick');
            });
            return item;
        },

        resetPicks: function () {
            _.each(this.itemSubviews, function (subview) {
                subview.deselect();
            });
        },

        realm: function () {
            var realm;
            _.each(this.itemSubviews, function (subview) {
                if (subview.selected) {
                    realm = subview.model;
                }
            });
            return realm;
        },

        listSelector: '.realms'
    });
});
