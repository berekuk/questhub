pp.views.Error = Backbone.View.extend({

    template: _.template($('#template-error').text()),

    render: function () {
        this.$el.html(this.template({response: jQuery.parseJSON(this.options.response.responseText) }));
        return this;
    }
});
