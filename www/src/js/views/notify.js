// TODO: check if we need to remove this view on close to avoid memory leak
define([
    'underscore',
    'views/proto/common',
    'text!templates/notify.html'
], function (_, Common, html) {

    return Common.extend({
        template: _.template(html),

        serialize: function () {
            return this.options;
        }
    });
});
