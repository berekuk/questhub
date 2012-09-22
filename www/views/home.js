pp.views.Home = Backbone.View.extend({

    template: _.template($('#template-home').text()),

    initialize: function () {
        this.setElement($(this.template()));
    }
});
