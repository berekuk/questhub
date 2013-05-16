define([
    'views/proto/common',
    'views/event/all',
    'text!templates/event-box.html'
], function (Common, eventViews, html) {
    return Common.extend({
        template: _.template(html),
        className: 'event-box-view',
        subviews: {
            '.subview': function () {
                var View = eventViews[this.model.name()];
                return new View({ model: this.model });
            },
        }
    });
});
