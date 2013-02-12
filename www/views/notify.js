pp.views.Notify = pp.View.Base.extend({

    template: _.template($('#template-notify').text()),

    render: function () {
        this.$el.html(this.template({text: this.options.text }));
        return this;
    }
});
