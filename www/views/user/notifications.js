define([
    'underscore',
    'views/proto/common',
    'text!templates/notifications.html'
], function (_, Common, html) {
    return Common.extend({
        template: _.template(html)
    });
});
