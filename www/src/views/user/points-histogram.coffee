define [
    "underscore"
    "views/proto/common"
    "text!templates/user/points-histogram.html"
], (_, Common, html) ->
    class extends Common
        template: _.template(html)

        render: ->
            super
            globalHistogram = @model.histogramPoints() # for normalization
            histogram = if @options.realm then @model.histogramPoints @options.realm else globalHistogram
            max = _.max(globalHistogram)
            bars = @$(".user-points-histogram")
            for i in [0 .. histogram.length - 1]
                weeks_back = histogram.length - i - 1
                title = if weeks_back == 0 then "this week" else if weeks_back == 1 then "last week" else "#{weeks_back} weeks ago"
                title = "#{histogram[i]} point#{if histogram[i] == 1 then '' else 's'} #{title}"
                bar = $("<div data-toggle='tooltip' data-placement='bottom' data-container='.user-big' title='#{title}'></div>")
                h = (100 * (histogram[i] / max))
                bar.css("height", (if h > 1 then "#{h}%" else "1px"))
                bars.append bar
            @$("[data-toggle=tooltip]").tooltip()
