pp.views.UserSettings = pp.View.Common.extend({

    t: 'user-settings',

    afterInitialize: function() {
        this.model.on('change', this.render, this);
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
