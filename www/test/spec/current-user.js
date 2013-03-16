define(['models/current-user', 'views/user/current'], function (currentUser, View) {
    describe('current user tests', function () {
        it("notifications icon", function () {
            var model = currentUser.clone();
            model.set({
                registered: 1,
                login: 'somebody',
                points: 3,
                _id: '513b9a2f01e3b87329000000',
                settings: {},
                notifications: []
            });

            var view = new View({ model: model });
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
});
