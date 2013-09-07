define [
    "jquery", "backbone",
    "views/proto/common",
    "models/current-user", "models/shared-models",
    "views/user/current", "views/quest/add",
    "text!templates/navbar.html"
], ($, Backbone, Common, currentUserModel, sharedModels, CurrentUser, QuestAdd, html) ->
    class extends Common
        template: _.template(html)

        initialize: ->
            super
            @listenTo Backbone, "pp:quiet-url-update", -> @render()

            $(window).on "scroll.navbar-sticked", =>
                if $(window).scrollTop() > 10
                    @$el.find("nav").addClass "sticked"
                else
                    @$el.find("nav").removeClass "sticked"

        # navbar usually don't get removed, but just to be safe...
        remove: ->
            $(window).off ".navbar-sticked"
            super

        serialize: ->
            params =
                realm: @getRealm()
                partial: @partial
                registered: currentUserModel.get("registered")
                currentUser: currentUserModel.get("login")

            params

        subviews:
            ".current-user-box": ->
                new CurrentUser model: currentUserModel

        lazySubviews: [".current-user-box"]
        currentUser: -> @subview ".current-user-box"

        getRealm: ->
            return unless @options.realm
            realm = sharedModels.realms.findWhere(id: @options.realm)
            throw "Oops" unless realm
            realm.toJSON()

        setRealm: (realm_id) ->
            @options.realm = realm_id
            @render()

            @currentUser().setRealm realm_id

        render: ->

            # wait for realms data; copy-paste from views/quest/add
            unless sharedModels.realms.length
                sharedModels.realms.fetch().success =>
                    @render()
                return

            super

            @currentUser() # force init/render

            @$el.find(".menu-item-" + @active).addClass "active" if @active

        setActive: (selector) ->
            @active = selector # don't render - views/app will call render() itself soon
