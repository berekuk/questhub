define([
    'views/realm/detail-collection',
    'models/realm-collection'
], function (RealmDetailCollection, RealmCollectionModel) {
    describe('realms list', function () {

        describe('when rendered', function () {
            var view = new RealmDetailCollection({
                collection: new RealmCollectionModel()
            });
            view.render();

            it("lists play perl realm", function () {
                expect(view.$el.html()).toContain('Play Perl');
            });
        });
    });
});
