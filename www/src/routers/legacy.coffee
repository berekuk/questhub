define [
    "backbone"
], (Backbone) ->
    redirect = (tmpl) ->
        (a1, a2, a3) ->
            newRoute = tmpl
            newRoute = newRoute.replace(":1", a1)
            newRoute = newRoute.replace(":2", a2)
            newRoute = newRoute.replace(":3", a3)
            Backbone.history.navigate "/" + newRoute,
                trigger: true
                replace: true

    class extends Backbone.Router
        routes:
            "feed": redirect("")
            "perl": redirect("realm/perl")
            "perl/": redirect("realm/perl")
            "players": redirect("")
            "explore": redirect("realm/chaos/explore")
            "explore/:tab": redirect("realm/chaos/explore/:1")
            "explore/:tab/tag/:tag": redirect("realm/chaos/explore/:1/tag/:2")
            ":realm/player/:login": redirect("player/:2")
            ":realm/explore": redirect("realm/:1/explore")
            ":realm/explore/:tab": redirect("realm/:1/explore/:2")
            ":realm/explore/:tab/tag/:tag": redirect("realm/:1/explore/:2/tag/:3")
            ":realm/players": redirect("realm/:1/players")
            ":realm/feed": redirect("realm/:1")
            ":realm/quest/:id": redirect("quest/:2")
