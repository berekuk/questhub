define [
    "underscore"
    "models/proto/paged-collection"
    "models/stencil"
], (_, Parent, Stencil) ->
    class extends Parent
        defaultCgi: ["comment_count=1"]
        baseUrl: "/api/stencil"
        cgi: ["realm", "tags"]
        model: Stencil

        allTags: ->
            _.uniq _.flatten @map (model) -> model.get("tags") || []
