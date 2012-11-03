pp.views.Home = Backbone.View.extend({

    template: _.template($('#template-home').text()),

    initialize: function () {
        console.log("rendering welcome screen");
        this.setElement($(this.template()));
    }
});
