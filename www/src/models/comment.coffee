define ["backbone", "jquery"], (Backbone, $) ->
    Backbone.Model.extend
        idAttribute: "_id"
        urlRoot: ->
            # backward compatibility, can be removed after migration to entity/eid
            entity = @get("entity") || "quest"
            eid = @get("eid") || @get("quest_id")

            return "/api/#{entity}/#{eid}/comment"

        like: -> @act "like"
        unlike: -> @act "unlike"

        act: (action) ->
            model = this

            # FIXME - copypasted from models/quest.js
            # TODO - send only on success?
            ga "send", "event", "comment", action
            mixpanel.track action + " comment"
            $.post(@url() + "/" + action).done ->
                model.fetch()
