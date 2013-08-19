define [
    "underscore", "jquery"
    "views/proto/common"
    "views/dashboard/profile/realm-collection"
    "text!templates/dashboard/profile.html"
], (_, $, Common, DashboardProfileRealmCollection, html) ->
    class extends Common
        template: _.template(html)
        activated: false

        initialize: ->
            super
            @model.loadStat()
                .success => @activate()

        subviews:
            ".dashboard-profile-scores-sv": -> new DashboardProfileRealmCollection model: @model

        features: ["tooltip"]
