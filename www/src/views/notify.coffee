# TODO: check if we need to remove this view on close to avoid memory leak
define ["underscore", "views/proto/common", "raw!templates/notify.html"], (_, Common, html) ->
    Common.extend
        template: _.template(html)
        serialize: ->
            @options


