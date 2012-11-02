pp.views.Register = Backbone.View.extend({
    events: {
       'click .submit': 'doRegister',
    },
    template: _.template($('script#template-register').text()),
    initialize: function () {
        this.setElement($(this.template()));
    },
    doRegister: function() {
        pp.app.router.navigate("/", { trigger: true });
    }
});
