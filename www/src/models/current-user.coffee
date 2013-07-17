define ["backbone", "jquery", "models/user"], (Backbone, $, User) ->
    CurrentUser = User.extend(
        initialize: ->
            @_tour = {}

        url: -> "/api/current_user"

        startTour: ->
            @_tour =
                realms: true
                profile: true
                feed: true

        getSetting: (name) ->
            settings = @get("settings")
            return unless settings
            settings[name]

        setSetting: (name, value) ->
            return unless @get("registered")
            settings = @get("settings")
            settings[name] = value
            @set "settings", settings
            return $.post("/api/settings/set/" + name + "/" + value)
            mixpanel.track "set setting",
                name: name
                value: value


        onTour: (page) ->
            result = @_tour[page]
            mixpanel.track page + " tour"  if result
            @_tour[page] = false # you can go on each tour only once; let's hope views code is sensible and doesn't call serialize() twice
            result

        dismissNotification: (_id) ->
            $.post @url() + "/dismiss_notification/" + _id

        needsToRegister: ->
            return if @get("registered")
            return true if @get("twitter")
            return true if @get("settings") and @get("settings").email and @get("settings").email_confirmed
            return

        followRealm: (id) ->
            mixpanel.track "follow realm", realm_id: id
            $.post("/api/follow_realm/" + id).always => @fetch()

        unfollowRealm: (id) ->
            mixpanel.track "unfollow realm", realm_id: id
            $.post("/api/unfollow_realm/" + id).always => @fetch()

        followUser: (login) ->
            mixpanel.track "follow user", following: login
            $.post "/api/user/#{login}/follow"

        unfollowUser: (login) ->
            mixpanel.track "unfollow user", following: login
            $.post "/api/user/#{login}/unfollow"
    )

    result = new CurrentUser()
    Backbone.listenTo result, "change", (e) ->
        if result.get("registered")
            mixpanel.people.set
                $username: result.get("login")
                $name: result.get("login")
                $email: result.get("settings").email

                # TODO - fill $created
                notify_likes: result.get("settings").notify_likes
                notify_comments: result.get("settings").notify_comments
                notify_invites: result.get("settings").notify_invites
                notify_followers: result.get("settings").notify_followers
            mixpanel.identify result.get("_id")

            mixpanel.name_tag result.get("login")

    result # singleton!
