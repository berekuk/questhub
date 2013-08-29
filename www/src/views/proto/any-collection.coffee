# Any collection view consisting of arbitrary list of subviews
#
# options:
#   generateItem(model): function generating one item subview
#   listSelector: css selector specifying the div to which subviews will be appended (or prepended, or whatever - see 'insertMethod')
define ["backbone", "underscore", "views/proto/common"], (Backbone, _, Common) ->
    class extends Common
        activated: false
        initialize: ->
            @listenToOnce @collection, "sync", @activate
            @listenTo @collection, "reset", => if @activated then @render() else @activate()
            @listenTo @collection, "add", @onAdd
            @listenTo @collection, "remove destroy", @render # TODO: optimize
            super

        itemSubviews: []

        # can be overriden if 'append' strategy doesn't fit you
        insertOne: (el, options) ->
            if options and options.prepend

                # this branch is not used in any real code, but still supported for the consistency with proto-paged.js implementation
                @$(@listSelector).prepend el
            else
                @$(@listSelector).append el

        removeItemSubviews: ->
            _.each @itemSubviews, (subview) ->
                subview.remove()

            @itemSubviews = []

        render: ->
            super

            # caching old itemSubviews to preserve them over re-rendering
            oldSubviews = {}
            for sv in @itemSubviews
                sv.detachFromDOM()
                oldSubviews[sv.model.id] = sv
            @itemSubviews = []

            # collection table is hidden initially - see https://github.com/berekuk/questhub/issues/61
            @$(@listSelector).show() if @collection.length

            @collection.each (model) =>
                if oldSubviews[model.id]
                    sv = oldSubviews[model.id]
                    delete oldSubviews[model.id]
                    @insertOne sv.el
                    sv.reattachToDOM()
                else
                    # new model in collection, let's create a view for it
                    @renderOne(model)

            # these subviews refer to models which are not present in collection anymore, so we're removing them
            for id, sv of oldSubviews
                sv.remove()

        generateItem: (model) ->
            alert "not implemented"

        renderOne: (model, options) ->
            view = @generateItem(model)
            @itemSubviews.push view
            view.render()
            @insertOne view.el, options

        onAdd: (model, collection, options) ->
            @$(@listSelector).show()
            @renderOne model, options # possible options: { prepend: true }

        remove: ->
            @removeItemSubviews()
            super

        detachFromDOM: ->
            super
            for sv in @itemSubviews
                sv.detachFromDOM()

        reattachToDOM: ->
            super
            for sv in @itemSubviews
                sv.reattachToDOM()
