define ["underscore", "views/proto/common", "text!templates/progress.html"], (_, Common, html) ->
    Common.extend
        template: _.template(html)
        on: ->
            return  if @$(".icon-spinner").is(":visible") # already on
            @off()
            that = this
            @progressPromise = window.setTimeout(->
                that.$(".icon-spinner").show()
            , 500)

        off: ->
            @$(".icon-spinner").hide()
            window.clearTimeout @progressPromise  if @progressPromise


