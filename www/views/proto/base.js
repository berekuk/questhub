define([
    'backbone', 'underscore', 'markdown'
], function (Backbone, _, markdown) {
    return Backbone.View.extend({
        partial: {
            user: _.template($('#partial-user').text()),
            quest_labels: _.template($('#partial-quest-labels').text()),
            edit_tools: _.template($('#partial-edit-tools').text()),
            markdown: markdown
        },

        initialize: function () {
            this.listenTo(Backbone, 'pp:logviews', function () {
                console.log(this);
            });
        }
    });
});
