define [
    "models/proto/paged-collection"
    "models/stencil"
], (Parent, Stencil) ->
    class extends Parent
        defaultCgi: ["comment_count=1"]
        baseUrl: "/api/stencil"
        cgi: ["realm"]
        model: Stencil
