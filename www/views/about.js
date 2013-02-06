pp.views.About = Backbone.View.extend({

    template: _.template($('#template-about').text()),

    initialize: function () {
        this.setElement($(this.template()));
    }
});
