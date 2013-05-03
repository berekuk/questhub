// FIXME - copypasted from views.progress.js
define([
    'underscore',
    'views/proto/common',
    'text!templates/progress-big.html'
], function (_, Common, html) {
    return Common.extend({
        template: _.template(html),

        on: function () {
            this.off();

            var that = this;
            this.progressPromise = window.setTimeout(function () {
                that.$('.progress').show();
            }, 1000);
        },

        off: function () {
            this.$('.progress').hide();
            if (this.progressPromise) {
                window.clearTimeout(this.progressPromise);
            }
        },
    });
});
