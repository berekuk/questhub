define [
    "backbone"
    "routers/proto/common"
    "views/about"
], (Backbone, Common, About) ->
    class extends Common
        routes:
            "about(/:tab)": "about"

        about: (tab) ->
            @appView.setPageView new About tab: tab
