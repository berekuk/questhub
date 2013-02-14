pp.views.QuestSmall = pp.View.Common.extend({
    t: 'quest-small',

    tagName: 'tr',

    className: 'quest-row',

    subviews: {
        '.likes': function () {
            return new pp.views.QuestLike({
                model: this.model,
                showButton: false
            });
        }
    },

    events: {
        'mouseenter': function (e) {
            this.subview('.likes').showButton();
        },
        'mouseleave': function (e) {
            this.subview('.likes').hideButton();
        }
    },

    afterRender: function () {
        var className = (this.model.get('status') == 'open' ? 'warning' : 'info');
        this.$el.addClass(className);
    },

    features: ['tooltip']
});
