define ["models/proto/paged-collection", "models/another-user"], (Parent, AnotherUser) ->
    Parent.extend
        cgi: ["sort", "order", "limit", "offset", "realm"]
        baseUrl: "/api/user"
        model: AnotherUser


