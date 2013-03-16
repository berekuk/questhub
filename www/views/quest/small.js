define([
    'underscore',
    'views/proto/common',
    'views/like',
    'text!templates/quest-small.html'
], function (_, Common, Like, html) {
    return Common.extend({
        template: _.template(html),

        tagName: 'tr',
        className: 'quest-row',

        events: {
            'mouseenter': function (e) {
                this.subview('.likes').showButton();
            },
            'mouseleave': function (e) {
                this.subview('.likes').hideButton();
            }
        },

        subviews: {
            '.likes': function () {
                return new Like({
                    model: this.model,
                    showButton: false
                });
            }
        },

        serialize: function () {
            var params = this.model.serialize();
            if (this.options.showAuthor) {
                params.showAuthor = true;
            }
            return params;
        },

        afterRender: function () {
            var className = 'quest-' + this.model.extStatus();
            this.$el.addClass(className);
        },

        features: ['tooltip']
    });
});
