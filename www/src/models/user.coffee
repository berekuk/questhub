define [
    "underscore", "backbone"
], (_, Backbone) ->
    class extends Backbone.Model
        initialize: -> alert "trying to instantiate abstract base class"

        histogramPoints: ->
            rph = _.clone @get "rph"
            rph ?= []

            reducePoints = (ph) ->
                return 0 unless ph?
                _.reduce(
                    _.values(ph),
                    ((memo, value) -> memo + value),
                    0
                )

            history = [reducePoints @get "rp"]
            for [1..8]
                rph.splice -1, 1
                sum = reducePoints rph[rph.length - 1]
                history.unshift sum

            result = []
            for i in [0 .. history.length - 2]
                result.push history[i + 1] - history[i]

            return result

        loadStat: ->
            $.getJSON "/api/user/#{ @get("login") }/stat", (data) =>
                @set 'stat', data
