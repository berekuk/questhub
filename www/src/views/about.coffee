define [
    "underscore"
    "views/proto/common"
    "text!templates/about.html"
    "text!templates/about/main.html"
    "text!templates/about/api.html"
], (_, Common, html, mainHtml, apiHtml) ->

    subviewClass = class extends Common
        initialize: ->
            @template = @options.template
            super

    class extends Common
        template: _.template(html)
        selfRender: true

        events:
            "click .nav li a": "switchTab"

        subTemplates:
            main: _.template mainHtml
            api: _.template apiHtml

        tab: 'main'

        initialize: ->
            @tab = @options.tab if @options.tab?
            super

        subviews:
            ".about-sv": ->
                template = @subTemplates[@tab]
                # TODO - error if template is undefined
                new subviewClass template: template

        serialize: ->
            tab: @tab

        switchTabByName: (tab) ->
            @tab = tab
            @initSubviews() # recreate tab subview
            @render()

        switchTab: (e) ->
            tab = $(e.target).attr("data-about-tab")
            @switchTabByName tab
            url = "/about"
            url += "/#{@tab}" if @tab? and @tab != "main"
            Backbone.history.navigate url
            Backbone.trigger "pp:quiet-url-update"
