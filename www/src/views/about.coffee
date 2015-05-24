define [
    "jquery", "underscore"
    "views/proto/common", "views/proto/tabbed"
    "raw!templates/about.html"
    "raw!templates/about/main.html"
    "raw!templates/about/api.html"
    "raw!templates/about/syntax.html"
    "raw!templates/about/feedback.html"
], ($, _, Common, Tabbed, html, mainHtml, apiHtml, syntaxHtml, feedbackHtml) ->

    subviewClass = class extends Common
        initialize: (options) ->
            @template = options.template
            super

    class extends Tabbed
        template: _.template html
        selfRender: true
        pageTitle: -> "About"

        events:
            "click .pills li a": "switchTab"

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
            syntax:
                url: '/syntax'
                subview: -> new subviewClass template: _.template syntaxHtml
            feedback:
                url: '/feedback'
                subview: -> new subviewClass template: _.template feedbackHtml

        switchTab: (e) ->
            @switchTabByName $(e.target).attr("data-about-tab")
