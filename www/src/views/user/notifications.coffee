define ["underscore", "views/proto/common", "text!templates/notifications.html"], (_, Common, html) ->
    Common.extend template: _.template(html)

