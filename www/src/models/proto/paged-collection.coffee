# see models/user-collection.js for implementation example
define ["backbone", "underscore"], (Backbone, _) ->
    Backbone.Collection.extend
    
        # all implementations should support at least 'limit' and 'offset'
        # if you override cgi, don't forget about it!
        cgi: ["limit", "offset"]
    
        # baseUrl is required
        defaultCgi: []
        url: ->
            url = @baseUrl
            cgi = @defaultCgi.slice(0) # clone
            _.each @cgi, ((key) ->
                cgi.push key + "=" + @options[key]  if @options[key]
            ), this
            url += "?" + cgi.join("&")  if cgi.length
            url

        initialize: (model, args) ->
            @options = args or {}
            @options.limit++  if @options.limit # always ask for one more
            @gotMore = true # optimistic :)

    
        # copied and adapted from Backbone.Collection.fetch
        # see http://documentcloud.github.com/backbone/docs/backbone.html#section-104
        # we have to do it manually, because we want to know the size of resp, and ignore the last item
        fetch: (options) ->
            options = (if options then _.clone(options) else {})
            options.parse = true  if options.parse is undefined
            success = options.success
            collection = this
            options.success = (resp) ->
                if collection.options.limit
                    collection.gotMore = (resp.length >= collection.options.limit)
                    resp.pop()  if collection.gotMore # always ignore last item, we asked for it only for the sake of knowing if there's more
                else
                    collection.gotMore = false # there was no limit, so we got everything there is
                method = (if options.update then "set" else "reset")
                collection[method] resp, options
                success collection, resp, options  if success
                collection.trigger "fetch-page"

            @sync "read", this, options

    
        # pager
        # supports { success: ..., error: ... } as a second parameter
        fetchMore: (count, options) ->
            @options.offset = @length
            @options.limit = count + 1
            options = {}  unless options
            options.update = true
            options.remove = false
            @fetch options


