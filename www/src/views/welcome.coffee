define [
    "underscore"
    "backbone"
    "views/proto/common"
    "views/user/signin", "views/realm/collection"
    "models/current-user", "models/shared-models"
    "raw!templates/welcome.html"
], (_, Backbone, Common, Signin, RealmCollection, currentUser, sharedModels, html) ->
    class extends Common
        template: _.template(html)
        selfRender: true
        activeMenuItem: "none"

        subviews:
            ".signin": ->
                new Signin(size: "large")

            ".realms-subview": ->
                collection = sharedModels.realms
                collection.fetch()
                new RealmCollection(collection: collection)

        initialize: ->
            super
            mixpanel.track "visit /welcome" unless currentUser.get("registered")
            @listenTo currentUser, "change:registered", ->
                Backbone.history.navigate "/",
                    trigger: true
                    replace: true
