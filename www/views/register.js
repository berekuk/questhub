pp.views.Register = pp.View.Common.extend({
    events: {
       'click .submit': 'doRegister',
       'keydown [name=login]': 'checkEnter'
    },

    t: 'register',

    afterInitialize: function () {
        _.bindAll(this);
        this.listenTo(this.model, 'change', this.checkUser);
    },

    checkUser: function () {
        // you can't see the registration form if you're already registered
        if (this.model.get("registered")) {
            this.remove();
            pp.app.router.navigate("/", { trigger: true });
            return;
        }
        // or if you're not authentificated yet
        if (!this.model.get("twitter")) {
            this.remove();
            pp.app.router.navigate("/welcome", { trigger: true });
            return;
        }
        this.render();
        return this;
    },

    checkEnter: function (e) {
        if (e.keyCode == 13) {
          // TODO - disable form elements while we're waiting for the server response
          // TODO - validate login
          this.doRegister();
        }
    },

    doRegister: function () {
        var login = this.$('[name=login]').val();
        var that = this;
        // TODO - what should we do if login is empty?
        $.post('/api/register', { login: login })
            .done(function (model, response) {
                pp.app.user.fetch({
                    success: function (model, response) {
                        pp.app.router.navigate("/", { trigger: true });
                    },
                    error: function (model, response) {
                        pp.app.router.navigate("/welcome", { trigger: true });
                        pp.app.onError(model, response);
                    }
                });
            })
            .fail(function (response) {
                pp.app.onError(false, response);
            })
    }
});
