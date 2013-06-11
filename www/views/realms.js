define([
    'underscore',
    'views/proto/common',
    'text!templates/realms.html'
], function (_, Common, html) {
    return Common.extend({
        template: _.template(html),
        selfRender: true,

        activeMenuItem: 'about' // FIXME
    });
});
