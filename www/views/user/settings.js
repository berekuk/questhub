pp.views.UserSettings = pp.View.Common.extend({
    events: {
       'click .resend-email-confirmation': 'resendEmailConfirmation',
       'keyup [name=email]': 'typing'
    },

    t: 'user-settings',

    afterInitialize: function() {
        this.model.on('change', this.render, this);
    },

    resendEmailConfirmation: function () {
        var btn = this.$('.resend-email-confirmation');
        if (btn.hasClass('disabled')) {
            return;
        }
        btn.addClass('disabled');

        $.post('http://play-perl.org/api/register/resend_email_confirmation', {})
        .done(function () {
            btn.text('Confirmation key sent');
        })
        .fail(function () {
            btn.text('Confirmation key resending failed');
        });
    },

    serialize: function () {
        var params = this.model.toJSON();
        params.hideEmailStatus = this.hideEmailStatus;
        return params;
    },

    start: function () {
        this.$('.email-status').show();
        this.hideEmailStatus = false;
    },

    typing: function() {
        // We need both.
        // First line hides status immediately...
        this.$('.email-status').hide();
        // Second line guarantees that it doesn't show up for a moment when we call save() and re-render.
        this.hideEmailStatus = true;
    },

    // i.e., parse the DOM and return the model params
    deserialize: function () {
        return {
            email: this.$('[name=email]').val(), // TODO - validate email
            notify_comments: this.$('[name=notify-comments]').is(':checked'),
            notify_likes: this.$('[name=notify-likes]').is(':checked')
        };
    },

    save: function(cbOptions) {
        this.model.save(this.deserialize(), cbOptions);
    },
});
