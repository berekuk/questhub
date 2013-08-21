define [
    "underscore"
    "views/quest/big"
    "text!templates/quest/feed.html"
], (_, QuestBig, html) ->
    class extends QuestBig
        template: _.template(html)
