define ["underscore", "views/proto/common", "raw!templates/notifications.html"], (_, Common, html) ->
    Common.extend template: _.template(html)

