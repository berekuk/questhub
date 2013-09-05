define [
    "underscore", "backbone"
], (_, Backbone) ->
    class extends Backbone.Model
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
            tags = _.uniq(tags)
            tags.sort()

        validateTagline: (tagLine) ->
            Boolean tagLine.match(/^\s*([\w-]+\s*,\s*)*([\w-]+\s*)?$/)
