pp.views.Notify = Backbone.View.extend({

    template: _.template($('#template-notify').text()),

    render: function () {
        this.$el.html(this.template({text: this.options.text }));
        return this;
    }
});
