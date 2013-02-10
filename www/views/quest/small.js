pp.views.QuestSmall = pp.View.Common.extend({
    t: 'quest-small',

    tagName: 'tr',

    afterRender: function () {
        var className = (this.model.get('status') == 'open' ? 'warning' : 'info');
        this.$el.addClass(className);
    },

    features: ['tooltip']
});
