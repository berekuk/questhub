define([
    'views/proto/common',
    'views/event/normal',
    'text!templates/event-box.html'
], function (Common, Event, html) {
    return Common.extend({
        template: _.template(html),
        subviews: {
            '.subview': function () {
                return new Event({ model: this.model });
            },
        },

        features: ['timeago'],
    });
});
