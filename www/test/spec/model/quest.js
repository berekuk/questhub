define([
    'models/quest',
    'jasmine-jquery'
], function (QuestModel) {
    describe('model/quest', function () {

        describe('serialize', function () {

            var model;
            var modelParams = {
                "ts" : 1360197975,
                "status" : "open",
                "_id" : "5112f9577a8f1d370b000002",
                "team" : ["badger"],
                "name" : "Badger Badger",
                "author" : "jonti",
                "tags" : ["feature"],
                "likes": ["mushroom", "snake"]
            };
            beforeEach(function () {
                model = new QuestModel(modelParams);
            });

            it('all properties', function () {
                expect(
                    model.serialize()
                ).toEqual(
                    _.extend(modelParams, {
                        'reward': 3,
                        'ext_status': 'open',
                        'my': false
                    })
                );
            });

            it('ext_status of open quest', function () {
                expect(model.serialize().ext_status).toEqual('open');
            });

            it('ext_status of unclaimed quest', function () {
                model.set('team', []);
                expect(model.serialize().ext_status).toEqual('unclaimed');
            });

            it('reward when likes are empty', function () {
                model.set('likes', []);
                expect(model.serialize().reward).toEqual(1);
            });

            it('reward when there are no likes', function () {
                model.unset('likes');
                expect(model.serialize().reward).toEqual(1);
            });
        });
    });
});
