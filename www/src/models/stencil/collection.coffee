define [
    "models/proto/paged-collection"
    "models/stencil"
], (Parent, Stencil) ->
    class extends Parent
        baseUrl: "/api/stencil"
        cgi: ["realm"]
        model: Stencil
