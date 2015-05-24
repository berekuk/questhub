# FIXME - copypasted from views.progress.js
define ["underscore", "views/proto/common", "raw!templates/progress-big.html"], (_, Common, html) ->
    Common.extend
        template: _.template(html)
        on: ->
            @off()
            that = this
            @progressPromise = window.setTimeout(->
                that.$(".progress").show()
            , 1000)

        off: ->
            @$(".progress").hide()
            window.clearTimeout @progressPromise  if @progressPromise


