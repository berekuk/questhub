describe("Play Perl Suite", function() {
    it("current user tests", function () {
        var model = new pp.models.CurrentUser({
            registered: 1,
            login: 'somebody',
            points: 3,
            _id: '5112f9297a8f1d360b000002',
            settings: {},
            notifications: []
        });

        // we don't load app.js, so we have to do it manually
        // TODO - split app.js into parts and load the relevant bits?
        pp.app.user = model;

        var view = new pp.views.CurrentUser({ model: model });
        view.render();
        expect(view.$el.find('.current-user-notifications-icon').length).toEqual(0);

        model.set('notifications', [
            {
                "params" : "preved",
                "ts" : 1362860591,
                "_id" : "513b9a2f01e3b87329000000",
                "user" : "somebody",
                "type" : "shout"
            },
            {
                "params" : "medved",
                "ts" : 1362860591,
                "_id" : "513b9a2f01e3b87329000000",
                "user" : "somebody",
                "type" : "shout"
            }
        ]);

        view.render();
        expect(view.$el.find('.current-user-notifications-icon').length).toEqual(1);
    });
});
