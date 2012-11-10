pp.views.Register = Backbone.View.extend({
    events: {
       'click .submit': 'doRegister',
    },

    template: _.template($('script#template-register').text()),

    initialize: function () {
        this.model = pp.app.user;

        this.model.on('change', this.checkUser, this);

        this.model.fetch();
    },

    checkUser: function () {
        // you can't see the registration form if you're already registered
        // or if you're not authentificated yet
        if (this.model.get("registered") || !this.model.get("twitter")) {
            this.remove();
            pp.app.router.navigate("/", { trigger: true });
            return;
        }
        this.render();
    },

    render: function () {
        this.$el.html(this.template);
    },

    doRegister: function () {
        var login = this.$('[name=login]').val();
        // TODO - what should we do if login is empty?
        $.post('/api/register', { login: login })
            .success(function () {
                pp.app.user.fetch();
                pp.app.router.navigate("/", { trigger: true });
            })
            .error(function () {
                alert("registration failed");
            });
    }
});
