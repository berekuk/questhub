define [
    "underscore"
    "models/another-user"
], (_, AnotherUserModel) ->
    describe "model/user", ->
        model = undefined
        createModel = ->
            model = new AnotherUserModel
                ts: 1360197975
                login: "somebody"
                _id: "3333"
                settings: {}
                notifications: []
                pic: "/another-user.png"
                rp:
                    europe: 5
                    asia: 7
                rph: [
                    { europe: 1, asia: 3 }
                    { europe: 2, asia: 3 }
                    { europe: 2, asia: 5 }
                ]

        describe "histogramPoints", ->
            beforeEach -> createModel()

            it "all realms", ->
                console.log model.histogramPoints()
                expect(
                    _.isEqual(
                        model.histogramPoints()
                        [ 0, 0, 0, 0, 4, 1, 2, 5 ]
                    )
                ).toEqual true

            it "single realm", ->
                console.log model.histogramPoints()
                expect(
                    _.isEqual(
                        model.histogramPoints("asia")
                        [ 0, 0, 0, 0, 3, 0, 2, 2 ]
                    )
                ).toEqual true
