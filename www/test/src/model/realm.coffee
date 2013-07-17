define [
    "models/realm"
], (RealmModel) ->
    describe "model/realm:", ->
        describe "with keepers", ->
            model = undefined
            beforeEach ->
                model = new RealmModel
                    id: "europe"
                    name: "Europe"
                    description: "europe-europe"
                    keepers: ["jasmine"]
                    pic: "europe.png"

            it "isKeeper is true", ->
                expect(model.serialize().isKeeper).toBe true

        describe "without keepers", ->
            model = undefined
            beforeEach ->
                model = new RealmModel
                    id: "europe"
                    name: "Europe"
                    description: "europe-europe"
                    keepers: []
                    pic: "europe.png"

            it "isKeeper is false", ->
                expect(model.serialize().isKeeper).not.toBe true
