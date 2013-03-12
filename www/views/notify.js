// TODO: check if we need to remove this view on close to avoid memory leak
define([
    'views/proto/common'
], function (Common) {
    return Common.extend({
        t: 'notify',

        serialize: function () {
            return this.options;
        }
    });
});
