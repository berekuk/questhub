define([
    'underscore',
    'views/proto/common',
    'text!templates/about.html'
], function (_, Common, html) {
    return Common.extend({
        template: _.template(html),
        selfRender: true
    });
});
