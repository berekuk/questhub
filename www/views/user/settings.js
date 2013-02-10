pp.views.UserSettings = Backbone.View.extend({
    events: {
        'click .btn-primary': 'submit',
    },

    template: _.template($('#template-user-settings').text()),

    initialize: function() {
        console.log('initialize settings view');
        _.bindAll(this);
        this.render();
        this.submitted = false;
    },

    disable: function() {
        this.$('.btn-primary').addClass('disabled');
        this.enabled = false;
    },

    enable: function() {
        this.$('.btn-primary').removeClass('disabled');
        this.enabled = true;
        this.submitted = false;
    },

    // TODO - common pp.View.Modal class
    render: function () {
        console.log('render settings view');
        this.setElement($(this.template()));

        this.$('.modal').modal().css({
            'width': function () {
                return ($(document).width() * .6) + 'px';
            },
            'margin-left': function () {
                return -($(this).width() / 2);
            }
        });
    },

    getEmail: function () {
        return this.$('.settings-notify-comments').val();
    },

    submit: function() {

        this.model.save({
          email: this.getEmail(),
        }, {
            'success': this.onSuccess,
            'error': pp.app.onError
        });

        this.submitted = true;
    },

    onSuccess: function (model) {
        this.collection.add(model);
        this.$('.modal').modal('hide');
    },
});
