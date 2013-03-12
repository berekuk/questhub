define([
    'underscore',
    'views/proto/base'
], function (_, Base) {
    return Base.extend({
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
            if (this.submitted || !this.getDescription()) {
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

            var qe = this.$('.quest-edit');
            this.$('#addQuest').modal().on('shown', function () {
                qe.focus();
            });
        },

        submit: function() {
            if (!this.enabled) {
                return;
            }

            var model_params = {
                name: this.getDescription()
            };

            var type = this.$('.quest-type-select button.active').attr('quest-type');
            if (type) {
                model_params.type = type;
            }

            var model = new this.collection.model();
            model.save(model_params, {
                'success': this.onSuccess
            });

            this.submitted = true;
            this.validate();
        },

        onSuccess: function (model) {
            this.collection.add(model, { prepend: true });
            this.$('#addQuest').modal('hide');
        },
    });
});
