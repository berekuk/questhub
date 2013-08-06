define [
    "models/current-user"
], (currentUser) ->
    result = {}

    result.settings =
        notify_likes: "1"
        notify_comments: "0"
        notify_invites: "1"
        email: "jasmine@example.com"
        email_confirmed: 1
        api_token: "0123456789abcdef0123456789abcdef"
        notify_followers: "0"
        newsletter: "0"

    result
