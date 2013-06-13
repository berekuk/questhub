define([
    'views/realm/detail-collection',
    'models/shared-models'
], function (RealmDetailCollection, sharedModels) {
    describe('realms list', function () {

        describe('when rendered', function () {
            var collection = sharedModels.realms;
            var view = new RealmDetailCollection({
                collection: collection
            });
            collection.trigger('sync'); // mocked by spec.js, firing the event to cause rendering

            it("lists realm descriptions", function () {
                expect(view.$el.html()).toContain('asia-asia');
            });
        });
    });
});
