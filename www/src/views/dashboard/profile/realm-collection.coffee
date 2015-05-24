define [
    "underscore"
    "views/proto/common"
    "views/user/points-histogram"
    "raw!templates/dashboard/profile/realm.html"
    "raw!templates/dashboard/profile/realm-collection.html"
], (_, Common, UserPointsHistogram, itemHtml, html) ->
    ItemView = class extends Common
        tagName: 'li'
        template: _.template(itemHtml)

        subviews:
            ".histogram-sv": ->
                console.log "building sv"
                new UserPointsHistogram model: @model, realm: @options.realm

        serialize: ->
            realm: @options.realm
            points: @options.points


    class extends Common
        template: _.template(html)
        render: ->
            super
            _.each @model.get("rp"), (points, realm) =>
                sv = new ItemView realm: realm, points: points, model: @model
                sv.render()
                @$("ul").append sv.$el
            # FIXME - cleanup!

        features: ["tooltip"]
