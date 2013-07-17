define [
    "backbone"
    "models/realm"
], (Backbone, Realm) ->
    class extends Backbone.Collection
        url: "/api/realm"
        model: Realm
