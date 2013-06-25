define([
    'underscore',
    'views/proto/common',
    'text!templates/progress.html'
], function (_, Common, html) {
    return Common.extend({
        template: _.template(html),

        on: function () {
            if (this.$('.icon-spinner').is(':visible')) {
                return; // already on
            }
            this.off();

            var that = this;
            this.progressPromise = window.setTimeout(function () {
                that.$('.icon-spinner').show();
            }, 500);
        },

        off: function () {
            this.$('.icon-spinner').hide();
            if (this.progressPromise) {
                window.clearTimeout(this.progressPromise);
            }
        },
    });
});
