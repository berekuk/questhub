define [
    "underscore"
    "views/proto/common"
    "views/user/signin", "views/realm/collection"
    "models/current-user", "models/shared-models"
    "text!templates/welcome.html"
], (_, Common, Signin, RealmCollection, currentUser, sharedModels, html) ->
    Common.extend
        template: _.template(html)
        selfRender: true
        activeMenuItem: "none"

        subviews:
            ".signin": ->
                new Signin()

            ".realms-subview": ->
                collection = sharedModels.realms
                collection.fetch()
                new RealmCollection(collection: collection)

        afterInitialize: ->
            mixpanel.track "visit /welcome" unless currentUser.get("registered")
            @listenTo currentUser, "change:registered", ->
                Backbone.history.navigate "/",
                    trigger: true
                    replace: true
