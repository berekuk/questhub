define [
    "models/proto/paged-collection"
    "models/search/item"
], (Parent, Item) ->
    class extends Parent
        baseUrl: "/api/search"
        cgi: ["q", "limit", "offset"]
        model: Item
