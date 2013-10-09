define [
    "underscore", "backbone"
    "routers/proto/common"
    "views/search/page"
], (_, Backbone, Common, SearchPage) ->
    class extends Common
        routes:
            "search": "search"
            "search?*queryString": "search"

        search: ->
            view = new SearchPage
                query: @queryParams 'q'

            view.render()
            @appView.setPageView view
