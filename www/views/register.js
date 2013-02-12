// see also for the similar code: views/quest/add.js
// TODO - refactor them both into pp.View.Form
pp.views.Register = pp.View.Common.extend({
    events: {
       'click .submit': 'doRegister',
       'keydown [name=login]': 'checkEnter',
       'keyup [name=login]': 'validate'
    },

    subviews: {
        '.settings-subview': function () {
            return new pp.views.UserSettings({
                model: new pp.models.UserSettings({ notify_likes: 1, notify_comments: 1 })
            });
        }
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

    afterRender: function () {
        this.validate();
    },

    checkEnter: function (e) {
        if (e.keyCode == 13) {
          this.doRegister();
        }
    },

    getLogin: function () {
        return this.$('[name=login]').val();
    },

    disable: function() {
        this.$('.submit').addClass('disabled');
        this.$('.progress').toggle(this.submitted);
        this.enabled = false;
    },

    enable: function() {
        this.$('.submit').removeClass('disabled');
        this.$('.progress').hide();
        this.enabled = true;
        this.submitted = false;
    },

    validate: function() {
        if (this.submitted || !this.getLogin()) {
            this.disable();
        }
        else {
            this.enable();
        }
    },

    doRegister: function () {
        if (!this.enabled) {
            return;
        }

        var that = this;

        // TODO - what should we do if login is empty?
        $.post('/api/register', {
            login: this.getLogin(),
            settings: JSON.stringify(this.settingsSubview.deserialize())
        }).done(function (model, response) {
            pp.app.user.fetch({
                success: function () {
                    pp.app.router.navigate("/", { trigger: true });
                },
                error: function (model, response) {
                    pp.app.router.navigate("/welcome", { trigger: true });
                    pp.app.onError(model, response);
                }
            });
        })
        .fail(function (response) {
            // TODO - detect "login already taken" exceptions and render them appropriately
            pp.app.onError(false, response);

            // let's hope that server didn't register the user before it returned a error
            that.submitted = false;
            that.validate();
        })

        this.submitted = true;
        this.validate();
    }
});
