define ["backbone", "models/proto/paged-collection", "models/event"], (Backbone, Parent, Event) ->
    Parent.extend
        baseUrl: "/api/event"
        cgi: ["limit", "offset", "realm", "for"]
        model: Event


