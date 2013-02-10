pp.views.UserSettings = pp.View.Common.extend({

    t: 'user-settings',

    afterInitialize: function() {
        this.model.on('change', this.render, this);
    },

    getEmail: function () {
        return this.$('[name=email]').val();
        // TODO - validate email
    },

    save: function(cbOptions) {
        this.model.save({
            email: this.getEmail(),
            notify_comments: this.$('[name=notify-comments]').is(':checked'),
            notify_likes: this.$('[name=notify-likes]').is(':checked')
        }, cbOptions);
    },
});
