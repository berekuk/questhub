define([
    'settings',
    'views/proto/common',
    'text!templates/realm.html'
], function (settings, Common, html) {
    return Common.extend({
        template: _.template(html),
    });
});
