define [
    "routers/proto/common", "views/not-found"
], (Common, NotFound) ->
    class extends Common
        routes:
            "*path": "notFound"

        notFound: (path) ->
            if path.match "/$"
                path = path.replace /\/$/, ''
                Backbone.history.navigate path, replace: true, trigger: true
                return

            @appView.setPageView new NotFound
