define([
    'underscore',
    'views/proto/base'
], function (_, Base) {
    return Base.extend({
        template: function () {
            var templateElem = $('#template-event-' + this.model.get('action') + '-' + this.model.get('object_type'));
            if (!templateElem.length) {
                templateElem = $('#template-event-unknown');
            }
            return _.template(templateElem.text());
        },

        render: function () {
            var template = this.template();
            var params = this.model.toJSON();
            params.partial = this.partial;
            this.$el.html(template(params));
            return this;
        }
    });
});
