define([
    'underscore', 'jquery',
    'views/proto/base',
    'text!templates/events.html'
], function (_, $, Base, html) {

    var el = $(html);
    var templates = {};
    el.find('script').each(function () {
        var item = $(this);
        templates[item.attr('class')] = _.template(item.text());
    });

    return Base.extend({
        template: function () {
            var eventName = this.model.name();
            if (templates[eventName]) {
                return templates[eventName];
            }
            else {
              return templates['unknown'];
            }
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
