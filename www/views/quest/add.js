define([
    'underscore', 'jquery',
    'views/proto/base',
    'text!templates/quest-add.html',
    'bootstrap'
], function (_, $, Base, html) {
    return Base.extend({
        template: _.template(html),

        events: {
            'click .quest-add': 'submit',
            'keyup [name=name]': 'nameEdit',
            'keyup [name=tags]': 'tagsEdit'
        },

        initialize: function() {
            _.bindAll(this);
            this.render();
            this.$('.icon-spinner').hide();
            this.submitted = false;
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
                return;
            }
            this.enable();

            var qt = this.$('.quest-tags-edit');
            var tagLine = this.$('[name=tags]').val();
            if (this.collection.model.prototype.validateTagline(tagLine)) {
                qt.removeClass('error');
                qt.find('input').tooltip('hide');
            }
            else {
                if (!qt.hasClass('error')) {
                    qt.addClass('error');

                    // .tooltip() loses focus for some reason, so we have to save it and restore
                    //
                    // Note that animation for this tooltip is disabled, to avoid race conditions.
                    // I'm not sure how to fix them...
                    // http://ricostacruz.com/backbone-patterns/#animation_buffer talks about animation buffers,
                    // but I don't know how to integrate it with bootstrap-tooltip.js code - it doesn't accept any "onShown" callback.
                    var oldFocus = $(':focus');
                    qt.find('input').tooltip('show');
                    $(oldFocus).focus();
                }

                this.disable();
            }
        },

        nameEdit: function (e) {
            this.validate();
            this.optimizeNameFont();
            this.checkEnter(e);
        },

        tagsEdit: function (e) {
            this.validate();
            this.checkEnter(e);
        },

        optimizeNameFont: function () {

            var input = this.$('.quest-edit');

            var testerId = '#quest-add-test-span';
            var tester = $(testerId);
            if (!tester.length) {
                tester = $('<span id="' + testerId + '"></span>');
                tester.css('display', 'none');
                tester.css('fontFamily', input.css('fontFamily'));
                this.$el.append(tester);
            }

            tester.css('fontSize', input.css('fontSize'));
            tester.text(input.val());

            if (tester.width() > input.width()) {
                var newFontSize = parseInt(input.css('fontSize')) - 1;
                if (newFontSize > 14) {
                    newFontSize += 'px';
                    input.css('fontSize', newFontSize);
                }
            }
        },

        getDescription: function() {
            return this.$('[name=name]').val();
        },

        getTags: function() {
            var tagLine = this.$('[name=tags]').val();
            return this.collection.model.prototype.tagline2tags(tagLine);
        },

        render: function () {
            this.setElement($(this.template()));

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
                name: this.getDescription(),
                realm: this.collection.options.realm
            };

            var tags = this.getTags();
            if (tags) {
                model_params.tags = tags;
            }

            var model = new this.collection.model();
            model.save(model_params, {
                'success': this.onSuccess
            });
            ga('send', 'event', 'quest', 'add');
            mixpanel.track('add quest');

            this.submitted = true;
            this.$('.icon-spinner').show();
            this.validate();
        },

        checkEnter: function (e) {
            if (e.keyCode == 13) {
              this.submit();
            }
        },

        onSuccess: function (model) {
            this.collection.add(model, { prepend: true });
            this.$('#addQuest').modal('hide');
        }
    });
});
