define [
    "underscore"
    "views/helper/react-container"
    "views/proto/common"
    "views/notify", "views/navbar"
    "text!templates/app.html"
], (_, ReactContainer, Common, Notify, Navbar, html) ->
    class extends Common
        template: _.template(html)
        realm_id: null
        subviews:
            ".navbar-subview": ->
                new ReactContainer Navbar, realm: @realm_id, null

        initialize: ->
            super

            # configure tracking
            mixpanel.init @partial.settings.mixpanel_id,
                track_pageview: false

            # TODO - configure localhost for debugging?
            ga "create", @partial.settings.analytics, window.location.host  if @partial.settings.analytics

        notify: (type, message) ->
            @$(".app-view-notifies").html ""
            @$(".app-view-notifies").append new Notify(
                type: type
                message: message
            ).render().el

        setPageView: (page) ->

            # the explanation of this pattern can be found in this article: http://lostechies.com/derickbailey/2011/09/15/zombies-run-managing-page-transitions-in-backbone-apps/
            # (note that the article is dated - it's pre-0.9.2, Backbone didn't have .listenTo() back then
            @_page.remove() if @_page
            @_page = page

            @$(".app-view-container").append page.$el

            unless @_page.isReactComponent
                menuItem = _.result(page, "activeMenuItem") or "none"
                @setActiveMenuItem menuItem

                @_page.on "change:page-title", => @updateTitle()
                @updateTitle()

                # FIXME - this leads to double-rendering navbar on the initial page load
                @updateRealm()

            window.scrollTo 0, 0


        updateRealm: ->
            realm = ((if @_page.realm then @_page.realm() else null))
            @realm_id = realm
            @subview(".navbar-subview").setProp 'realm', @realm_id

        updateTitle: ->
            title = if @_page.pageTitle then @_page.pageTitle() else null
            @setWindowTitle title

        setWindowTitle: (title) ->
            if title
                window.document.title = "#{title} - Questhub.io"
            else
                window.document.title = "Questhub.io"

        setActiveMenuItem: (menuItem) ->
            @subview(".navbar-subview").setProp 'active', menuItem
