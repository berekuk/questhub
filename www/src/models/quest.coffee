define ["backbone", "jquery", "models/current-user"], (Backbone, $, currentUser) ->
    Backbone.Model.extend
        idAttribute: "_id"
        urlRoot: "/api/quest"

        like: -> @act "like"
        unlike: -> @act "unlike"

        invite: (invitee) -> @act "invite", invitee: invitee
        uninvite: (invitee) -> @act "uninvite", invitee: invitee 

        join: -> @act "join"
        leave: -> @act "leave"
        close: -> @act "close"
        abandon: -> @act "abandon"
        resurrect: -> @act "resurrect"
        reopen: -> @act "reopen"

        act: (action, params) ->
            model = this

            # FIXME - copypasted from models/comment.js
            # TODO - send only on success?
            ga "send", "event", "quest", action
            mixpanel.track action + " quest"
            $.post(@url() + "/" + action, params).success ->
                model.fetch()

                # update of the current user's quest causes update in points
                currentUser.fetch()  if _.contains(model.get("team"), currentUser.get("login"))

            # TODO - error handling?
            @trigger "act"

        comment_count: ->
            @get("comment_count") or 0

        like_count: ->
            likes = @get("likes")
            return likes.length  if likes
            0

        extStatus: ->
            status = @get("status")
            return "unclaimed"  if status is "open" and @get("team").length is 0
            status

        isOwned: ->
            currentLogin = currentUser.get("login")
            return  if not currentLogin or not currentLogin.length
            _.contains @get("team") or [], currentLogin


        # augments attributes with 'ext_status'
        serialize: ->
            params = @toJSON()
            params.ext_status = @extStatus()
            if params.tags
                params.tags = params.tags.sort()
            else
                params.tags = []
            params.my = @isOwned()
            params.likes = []  unless params.likes
            params


        # static methods
        tagline2tags: (tagLine) ->
            tags = tagLine.split(",")
            tags = _.map(tags, (tag) ->
                tag = tag.replace(/^\s+|\s+$/g, "")
                tag
            )
            tags = _.filter(tags, (tag) ->
                tag isnt ""
            )
            tags.sort()

        validateTagline: (tagLine) ->
            Boolean tagLine.match(/^\s*([\w-]+\s*,\s*)*([\w-]+\s*)?$/)
