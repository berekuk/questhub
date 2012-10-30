pp.views.Error = Backbone.View.extend({

    template: _.template($('#template-error').text()),

    render: function () {
        var response = {};
        try {
            response = jQuery.parseJSON(this.options.response.responseText);
        }
        catch(e) {}

        this.$el.html(this.template({ response: response }));
        return this;
    }
});
