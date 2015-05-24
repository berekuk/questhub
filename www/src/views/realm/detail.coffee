define [
  "underscore"
  "views/proto/common"
  "views/realm/controls"
  "raw!templates/realm/detail.html"
], (_, Common, RealmControls, html) ->
    Common.extend
        template: _.template(html)
        subviews:
            ".controls-subview": ->
                new RealmControls(model: @model)
