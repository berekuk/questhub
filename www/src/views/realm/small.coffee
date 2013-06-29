define ["settings", "views/proto/common", "text!templates/realm-small.html"], (settings, Common, html) ->
    Common.extend template: _.template(html)

