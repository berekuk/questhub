define [
    "underscore", "jquery"
    "views/proto/common"
    "raw!templates/quest/completed.html"
], (_, $, Common, html) ->
    class extends Common
        template: _.template(html)
        events:
            "click .btn-primary": "stop"

        initialize: ->
            super
            @setElement $("#quest-completed-modal")
            @user = @options.user

        start: ->
            @render()
            @$(".modal").modal "show"
            $.getScript "http://platform.twitter.com/widgets.js"

        stop: ->
            @$(".modal").modal "hide"

        serialize: ->
            params = super
            params.gotTwitter = Boolean(@user.get("twitter"))
            params.points = parseInt(params.points)
            params.totalPoints = @user.get("rp")[@model.get("realm")]
            params.totalPoints ?= 0
            params.totalPoints = parseInt(params.totalPoints)
            params.totalPoints += params.points
            params

        render: ->
            super

            histogram = @user.histogramPoints(@model.get("realm"))
            oldCurrentWeekPoints = histogram[histogram.length - 1]
            oldCurrentWeekPoints ?= 0
            currentWeekPoints = oldCurrentWeekPoints + @model.get("points")
            lastWeekPoints = histogram[histogram.length - 2]
            lastWeekPoints ?= 0

            p2w = (points) =>
                maxPoints = Math.max currentWeekPoints, lastWeekPoints, 1
                # we never go over 70%
                widthPerPoint = 70 / maxPoints
                (points * widthPerPoint) + "%"

            prepareBar = (el, points) ->
                el.find("._bar").css("width", p2w(points))
                el.find(".reward-points").html(points)

            @$(".modal").on "shown", (e) =>
                return unless $(e.target).hasClass("modal")
                prepareBar @$(".last-week-bar"), lastWeekPoints
                prepareBar @$(".current-week-bar"), oldCurrentWeekPoints

                duration = 400
                delay = 500
                duration += 100 * @model.get "points" # slow down if there are many points
                easing = 'easeInSine'

                currentBar = @$(".current-week-bar")
                currentBar.addClass "quest-completed-bar-animated"
                currentBar.find("._bar").delay(delay).animate({ "width": p2w(currentWeekPoints) }, {
                    duration: duration
                    easing: easing
                    complete: =>
                        currentBar.removeClass "quest-completed-bar-animated"
                })

                $({ points: oldCurrentWeekPoints }).delay(delay).animate({ points: currentWeekPoints }, {
                    duration: duration
                    easing: easing
                    step: (now) =>
                        @$(".current-week-bar .reward-points").html(Math.floor(now))
                    complete: =>
                        # can't trust Math.floor to round up correctly ("now" can stop at .99999999)
                        @$(".current-week-bar .reward-points").html(currentWeekPoints)
                })

        features: ["tooltip"]
