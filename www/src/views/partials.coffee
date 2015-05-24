define [
    "jquery", "underscore"
    "markdown", "settings"
    "raw!templates/partials.html"
], ($, _, markdown, settings, html) ->
    el = $(html)

    result =
        markdown: markdown
        settings: settings

    realmTab2url =
        stencils: '/stencils'
        activity: ''
        quests: '/explore'
        players: '/players'
    result.realm_link = (realm_id, tab) -> "/realm/#{realm_id}#{realmTab2url[tab]}"

    userTab2url =
        quests: ''
        activity: '/activity'
        profile: '/profile'
    result.user_link = (login, tab) -> "/player/#{login}#{userTab2url[tab]}"

    userQuestsTab2url =
        open: ''
        closed: '/quest/closed'
        abandoned: '/quest/abandoned'
    result.user_quests_link = (login, tab) -> "/player/#{login}#{userQuestsTab2url[tab]}"

    el.find("script").each ->
        name = @.className
        name = name.replace /-/g, "_"
        result[name] = _.template $(@).text()

    result
