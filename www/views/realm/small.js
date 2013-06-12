define([
    'settings',
    'views/proto/common',
    'text!templates/realm-small.html'
], function (settings, Common, html) {
    return Common.extend({
        template: _.template(html),
    });
});
