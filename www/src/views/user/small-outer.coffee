define [
    "underscore"
    "views/proto/common"
    "views/user/small"
    "views/helper/react-container"
    "raw!templates/user/small-outer.html"
], (_, Common, UserSmall, ReactContainer, html) ->
    class extends Common
        template: _.template html
        tagName: "tr"

        subviews:
            ".sv": ->
                new ReactContainer UserSmall, model: @options.model, realm: @options.realm, null
