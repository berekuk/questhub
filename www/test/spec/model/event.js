define([
    'models/event'
], function (EventModel) {
    describe('model/event', function () {

        describe('name', function () {

            var model;
            var modelParams = {
                "comment" : {
                    "_id" : "5187d5eb9174e8db1000001e",
                    "body" : "body text",
                    "author" : "berekuk",
                    "quest_id" : "517629ce5c6a12cf78000002"
                },
                "quest" : {
                    "_id" : "517629ce5c6a12cf78000002",
                    "status" : "open",
                    "ts" : 1366698446,
                    "name" : "quest name",
                    "author" : "anykeen",
                    "tags" : [],
                    "watchers" : [
                        "ideali"
                    ],
                    "realm" : "chaos",
                    "likes" : [
                        "berekuk",
                        "ideali"
                    ],
                    "team" : [
                        "anykeen"
                    ]
                },
                "type" : "add-comment",
                "ts" : 1367856619,
                "_id" : "5187d5eb9174e8db1000001f",
                "author" : "berekuk",
                "realm" : "chaos",
                "quest_id" : "517629ce5c6a12cf78000002",
                "comment_id" : "5187d5eb9174e8db1000001e"
            };
            beforeEach(function () {
                model = new EventModel(modelParams);
            });

            it('name', function () {
                expect(
                    model.name()
                ).toEqual(
                    'add-comment'
                );
            });
        });
    });
});
