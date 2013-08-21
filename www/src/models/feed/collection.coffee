define [
    "models/proto/paged-collection"
    "models/feed/item"
], (Parent, Item) ->
    class extends Parent
        baseUrl: "/api/feed"
        cgi: ["limit", "offset", "for"]
        model: Item
