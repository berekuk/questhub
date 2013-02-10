pp.views.EventBox = pp.View.Common.extend({
    t: 'event-any',
    subviews: {
        '.subview': function () {
            return new pp.views.Event({ model: this.model });
        },
    },

    serialize: function () {
        return this.model.toJSON();
    },

    features: ['timeago'],
});
