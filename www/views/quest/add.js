define([
    'underscore', 'jquery',
    'views/proto/base',
    'text!templates/quest-add.html'
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
            this.enable();
            if (this.submitted || !this.getDescription()) {
                this.disable();
            }

            var tagLine = this.$('[name=tags]').val();
            if (tagLine.match(/^\s*([\w-]+\s*,\s*)*([\w-]+\s*)?$/)) {
                this.$('.quest-tags-edit').removeClass('error');
            }
            else {
                this.$('.quest-tags-edit').addClass('error');
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
            var tags = tagLine.split(',');
            tags = _.map(tags, function (tag) {
                tag = tag.replace(/^\s+|\s+$/g, '');
                return tag;
            });
            tags = _.filter(tags, function (tag) {
                return (tag != '');
            });
            return tags;
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
                name: this.getDescription()
            };

            var tags = this.getTags();
            if (tags) {
                model_params.tags = tags;
            }

            var model = new this.collection.model();
            model.save(model_params, {
                'success': this.onSuccess
            });

            this.submitted = true;
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
        },
    });
});
