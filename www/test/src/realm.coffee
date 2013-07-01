define ["views/realm/detail-collection", "models/shared-models"], (RealmDetailCollection, sharedModels) ->
  describe "realms list", ->
    describe "when rendered", ->
      collection = sharedModels.realms
      view = new RealmDetailCollection(collection: collection)
      collection.trigger "sync" # mocked by spec.js, firing the event to cause rendering
      it "lists realm descriptions", ->
        expect(view.$el.html()).toContain "asia-asia"




