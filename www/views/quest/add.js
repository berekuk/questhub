pp.views.QuestAdd = Backbone.View.extend({
    events: {
        'click .quest-add': 'submit',
        'click .quest-type-select button': 'setType',
        'keyup [name=name]': 'validate'
    },

    template: _.template($('#template-quest-add').text()),

    initialize: function() {
        _.bindAll(this);
        this.render();
        this.submitted = false;
        this.gotType = false;
        this.validate();
    },

    setType: function(e) {
        // Radio buttons - activate clicked button and disactivate all the others.
        // We can't use native radio buttons from bootstrap because of unpredictable event triggering order, btw.
        // See http://stackoverflow.com/questions/9262827/twitter-bootstrap-onclick-event-on-buttons-radio for details.
        $(e.target.parentElement).find('.active').removeClass('btn-primary');
        $(e.target.parentElement).find('.active').removeClass('active');
        $(e.target).button('toggle');
        $(e.target).addClass('btn-primary');
        this.gotType = true;
        this.validate();
    },

    disable: function() {
        this.$('.quest-add').addClass('disabled');
        this.enabled = false;
    },

    enable: function() {
        this.$('.quest-add').removeClass('disabled');
        this.enabled = true;
        this.submitted = false;
    },

    validate: function() {
        if (this.submitted || !this.gotType || !this.getDescription()) {
            this.disable();
        }
        else {
            this.enable();
        }
    },

    getDescription: function() {
        return this.$('[name=name]').val();
    },

    render: function () {
        this.setElement($(this.template()));

        this.$('#addQuest').modal().css({
            'width': function () {
                return ($(document).width() * .8) + 'px';
            },
            'margin-left': function () {
                return -($(this).width() / 2);
            }
        });
    },

    submit: function() {
        if (!this.enabled) {
            return;
        }

        var type = this.$('.quest-type-select button.active').attr('quest-type');
        if (!type) {
            type = 'other';
        }

        var model = new this.collection.model();
        model.save({
            name: this.getDescription(),
            type: type
        }, {
            'success': this.onSuccess,
            'error': pp.app.onError
        });

        this.submitted = true;
        this.validate();
    },

    onSuccess: function (model) {
        this.collection.add(model);
        this.$('#addQuest').modal('hide');
    },
});
