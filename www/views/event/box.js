define([
    'views/proto/common',
    'views/event/any',
    'text!templates/event-box.html'
], function (Common, Event, html) {
    return Common.extend({
        template: _.template(html),
        className: 'event-box-view',
        subviews: {
            '.subview': function () {
                return new Event({ model: this.model });
            },
        },

        serialize: function () {
            var params = this.model.toJSON();
            params.showRealm = this.options.showRealm;
            return params;
        }
    });
});
