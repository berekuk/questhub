define [
    "underscore"
    "views/proto/common", "views/proto/tabbed"
    "text!templates/about.html"
    "text!templates/about/main.html"
    "text!templates/about/api.html"
], (_, Common, Tabbed, html, mainHtml, apiHtml) ->

    subviewClass = class extends Common
        initialize: ->
            @template = @options.template
            super

    class extends Tabbed
        template: _.template html
        selfRender: true

        events:
            "click .nav li a": "switchTab"

        urlRoot: '/about'
        tab: 'main'
        tabSubview: '.about-sv'
        tabs:
            main:
                url: ''
                subview: -> new subviewClass template: _.template mainHtml
            api:
                url: '/api'
                subview: -> new subviewClass template: _.template apiHtml

        switchTab: (e) ->
            @switchTabByName $(e.target).attr("data-about-tab")
