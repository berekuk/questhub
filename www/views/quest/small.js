pp.views.QuestSmall = Backbone.View.extend({
    template: _.template($('#template-quest-small').text()),

    render: function () {
        this.setElement($(this.template(this.model.toJSON())));
        this.$el.find('[data-toggle=tooltip]').tooltip();
        return this;
    }
});
