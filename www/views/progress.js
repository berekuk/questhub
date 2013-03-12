define([
    'views/proto/common'
], function (Common) {
    return Common.extend({
        t: 'progress',

        on: function () {
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
