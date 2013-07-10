define [
    "models/proto/paged-collection"
], (Parent) ->
    class extends Parent
        baseUrl: "/api/stencil"
        cgi: ["realm"]
