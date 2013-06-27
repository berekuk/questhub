define ["underscore", "views/proto/common", "text!templates/about.html"], (_, Common, html) ->
    Common.extend
        template: _.template(html)
        selfRender: true
        activeMenuItem: "about"


