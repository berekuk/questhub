#
# * Any collection view consisting of arbitrary list of subviews
# *
# * options:
# *   generateItem(model): function generating one item subview
# *   listSelector: css selector specifying the div to which subviews will be appended (or prepended, or whatever - see 'insertMethod')
# *
# * Note that this view defines 'afterInitialize' and 'afterRender'. Sorry, future me.
#
define ["backbone", "underscore", "views/proto/common"], (Backbone, _, Common) ->
    class extends Common
        activated: false
        afterInitialize: ->
            @listenTo @collection, "sync", @activate
            @listenTo @collection, "reset", @activate
            @listenTo @collection, "add", @onAdd
            @listenTo @collection, "remove", @render # TODO: optimize

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

        afterRender: ->
            @removeItemSubviews()
            @$(@listSelector).show() if @collection.length # collection table is hidden initially - see https://github.com/berekuk/play-perl/issues/61
            @collection.each @renderOne, this

        generateItem: (model) ->
            alert "not implemented"

        renderOne: (model, options) ->
            view = @generateItem(model)
            @itemSubviews.push view
            @insertOne view.render().el, options

        onAdd: (model, collection, options) ->
            @$(@listSelector).show()
            @renderOne model, options # possible options: { prepend: true }

        remove: ->
            @removeItemSubviews()
            super
