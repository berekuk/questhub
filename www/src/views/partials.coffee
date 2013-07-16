define [
    "underscore", "markdown"
    "settings"
    "text!templates/partials.html"
], (_, markdown, settings, html) ->
    el = $(html)

    result =
        markdown: markdown
        settings: settings

    el.find("script").each ->
        name = @.className
        name = name.replace /-/g, "_"
        result[name] = _.template $(@).text()

    result
