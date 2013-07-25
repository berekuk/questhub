define [
  "views/proto/common"
  "views/realm/tabs"
  "text!templates/realm/submenu.html"
], (Common, RealmTabs, html) ->
    class extends Common
        template: _.template(html)

        subviews:
            ".realm-tabs-sv": ->
                new RealmTabs
                    model: @model
                    navigate: true
                    small: true
