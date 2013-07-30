define ["underscore", "views/proto/common", "text!templates/progress.html"], (_, Common, html) ->
    Common.extend
        template: _.template(html)
        on: ->
            return if @$(".icon-spinner").is(":visible") # already on
            @off()
            @progressPromise = window.setTimeout(=>
                @$(".icon-spinner").show()
            , 500)

        off: ->
            @$(".icon-spinner").hide()
            window.clearTimeout @progressPromise  if @progressPromise


