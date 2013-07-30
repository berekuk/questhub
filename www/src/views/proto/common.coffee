# Common questhub view.
# It declares render() itself, you need to declare serialize() instead of render.
# If you want to do some more work on render(), call the parent's implementation with super.
#
# It also declares initialize().
# If you want to do some more work on render(), don't forget to call super.
#
# options:
#   t: 'blah' - use '#template-blah' template
#   selfRender: this flag causes initialize() to call render()
#   serialize: should prepare params for the template; defaults to self.model.toJSON(), or {} if model is not defined
#   features: array with features that should be enabled in html after rendering; possible values: ['timeago', 'tooltip']
#   subviews: events-style hash with subviews; see assign pattern in http://ianstormtaylor.com/assigning-backbone-subviews-made-even-cleaner/
#   activated: if false, turn render() into a null operation until someone calls activate(); also, don't initialize subviews until activation
#
# subviews usage example:
#   subviews: {
#     '.foo-item': function() { return new Foo() },
#     '.bar-item': 'barSubview',
#   },
#   barSubview: function() {
#      return new Bar(); // will be called only once and cached
#   }
#
# Note that this class overrides remove(), calling remove() for all subviews for you. Die, zombies.
define [
    "backbone", "underscore",
    "views/proto/base",
    "jquery.timeago", "bootstrap" # for features
], (Backbone, _, Base) ->
    "use strict"
    class extends Base

        # TODO - detect 't' default value from the class name somehow? is it possible in JS?
        initialize: ->
            super
            @initSubviews() if @activated
            @render() if @selfRender

        initSubviews: ->
            # this was a warning situation in the past, but now views/explore.js legitimately re-initializes subviews
            # (TODO - hmm, or does it?)
            #            console.log('initSubviews is called twice!');
            @_subviewInstances = {}
            _.each _.keys(_.result(this, "subviews")), (key) =>
                @subview key # will perform the lazy init


        rebuildSubview: (key) ->
            value = _.result(this, "subviews")[key]
            method = value
            method = this[value] unless _.isFunction(method)
            throw new Error("Method '#{value}' does not exist") unless method
            method = _.bind(method, this)
            subview = method()

            if prev = @_subviewInstances[key]
                prev.trigger('detach-subview') # allow subview to do additional cleanups
                prev.stopListening() # cleanup jquery events
            @_subviewInstances[key] = subview

            # useless on initial init - view's element is an empty div - but can come in handy if someone calls rebuildSubview leter
            subview.setElement(@$(key))

            subview


        # get a subview from cache, lazily instantiate it if necessary
        subview: (key) ->
            @rebuildSubview key unless @_subviewInstances[key]
            @_subviewInstances[key]

        serialize: ->
            if @model
                if @model.serialize
                    return @model.serialize()
                else
                    return @model.toJSON()
            else
                return {}

        features: []
        subviews: -> {}
        activated: true
        activate: ->
            unless @activated
                @activated = true
                @initSubviews()
            @render()

        render: ->
            return  unless @activated
            params = @serialize()
            params.partial = @partial
            @$el.html @template(params)

            # TODO - enable all features by default?
            # how much overhead would that create?
            _.each @features, (feature) =>
                if feature is "timeago"
                    @$("time.timeago").timeago()
                else if feature is "tooltip"
                    @$("[data-toggle=tooltip]").tooltip()
                else
                    console.log "unknown feature: " + feature

            _.each _.keys(@_subviewInstances), (key) =>
                subview = @_subviewInstances[key]
                subview.setElement(@$(key)).render()

            @trigger "render"
            this

        removeSubviews: ->
            # _subviewInstances can be undefined if view was never activated
            if @_subviewInstances
                _.each @_subviewInstances, (subview) =>
                    subview.remove()

        remove: ->
            @removeSubviews()
            super
