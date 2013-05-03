define([
    'settings',
    'views/proto/common',
    'text!templates/realm-pick.html'
], function (settings, Common, html) {
    return Common.extend({
        template: _.template(html),

        selected: false,

        events: {
            'click .realm-logo': 'select'
        },

        serialize: function () {
            var params = this.model.toJSON();
            params.selected = this.selected;
            return params;
        },

        deselect: function () {
            this.selected = false;
            this.$('.realm-logo').removeClass('realm-logo-selected');
        },

        select: function () {
            this.options.picker.resetPicks();
            this.selected = true;
            this.$('.realm-logo').addClass('realm-logo-selected');
            this.trigger('pick');
        }
    });
});
