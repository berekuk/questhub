define([
    'views/proto/common',
    'views/event/normal'
], function (Common, Event) {
    return Common.extend({
        t: 'event-any',
        subviews: {
            '.subview': function () {
                return new Event({ model: this.model });
            },
        },

        features: ['timeago'],
    });
});
