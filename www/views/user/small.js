// This is a model-less view.
// It accepts { "login": "foo" } option and doesn't need anything else.
pp.views.UserSmall = Backbone.View.extend({
    template: _.template($('#template-user-small').text()),

    render: function () {
        this.$el.html(this.template(this.options));
        return this;
    }
});
