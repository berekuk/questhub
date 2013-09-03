define [
    "routers/proto/common", "views/not-found"
], (Common, NotFound) ->
    class extends Common
        routes:
            "*path": "notFound"

        notFound: ->
            @appView.setPageView new NotFound
