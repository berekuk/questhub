define([
    'backbone', 'underscore', 'markdown', 'settings',
    'views/partials'
], function (Backbone, _, markdown, settings, partials) {
    return Backbone.View.extend({
        partial: partials,

        initialize: function () {
            this.listenTo(Backbone, 'pp:logviews', function () {
                console.log(this);
            });
        }
    });
});
