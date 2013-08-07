define [
    "underscore", "markdown"
    "settings"
    "text!templates/partials.html"
], (_, markdown, settings, html) ->
    el = $(html)

    result =
        markdown: markdown
        settings: settings

    tab2url =
        stencils: '/stencils'
        activity: ''
        quests: '/explore'
        players: '/players'
    result.realm_link = (realm_id, tab) -> "/realm/#{realm_id}#{tab2url[tab]}"

    el.find("script").each ->
        name = @.className
        name = name.replace /-/g, "_"
        result[name] = _.template $(@).text()

    result
