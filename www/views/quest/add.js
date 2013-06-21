define([
    'underscore', 'jquery',
    'models/shared-models',
    'models/quest',
    'views/proto/base',
    'text!templates/quest-add.html',
    'bootstrap', 'jquery.autosize'
], function (_, $, sharedModels, QuestModel, Base, html) {
    return Base.extend({
        template: _.template(html),

        events: {
            'click .quest-add': 'submit',
            'keyup [name=name]': 'nameEdit',
            'keyup [name=tags]': 'tagsEdit',
            'click .quest-add-realm button': function () {
                this.validate({ checkRealm: false });
            }
        },

        initialize: function() {
            _.bindAll(this);
            $('#modal-storage').append(this.$el);
            this.render();
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

        validate: function(options) {
            if (
                (!options || options.checkRealm !== false)
                && !this.getRealm()
            ) {
                this.disable();
                return;
            }

            this.$('.quest-add-realm-reminder').hide();

            if (this.submitted || !this.getName()) {
                this.disable();
                return;
            }
            this.enable();

            var qt = this.$('.quest-tags-edit');
            var tagLine = this.$('[name=tags]').val();
            if (QuestModel.prototype.validateTagline(tagLine)) {
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

            var input = this.$('.quest-edit-name');

            var testerId = '#quest-add-test-span';
            var tester = $(testerId);
            if (!tester.length) {
                tester = $('<span id="' + testerId + '"></span>');
                tester.css('display', 'none');
                tester.css('fontFamily', input.css('fontFamily'));
                this.$el.append(tester);
            }

            tester.css('fontSize', input.css('fontSize'));
            tester.css('lineHeight', input.css('lineHeight'));
            tester.text(input.val());

            if (tester.width() > input.width()) {
                var newFontSize = parseInt(input.css('fontSize')) - 1;
                if (newFontSize > 14) {
                    newFontSize += 'px';
                    input.css('fontSize', newFontSize);
                    input.css('lineHeight', newFontSize);
                }
            }
        },

        getName: function () {
            return this.$('[name=name]').val();
        },

        getDescription: function () {
            return this.$('[name=description]').val();
        },

        getTags: function () {
            var tagLine = this.$('[name=tags]').val();
            return QuestModel.prototype.tagline2tags(tagLine);
        },

        getRealm: function () {
            return this.$('.quest-add-realm .active').attr('data-realm-id');
        },

        render: function () {
            var that = this;

            if (!sharedModels.realms.length) {
                sharedModels.realms.fetch()
                .success(function () {
                    that.render();
                });
                return;
            }

            var defaultRealm = this.options.realm;
            if (!defaultRealm) {
                var userRealms = sharedModels.currentUser.get('realms');
                if (userRealms && userRealms.length == 1) {
                    defaultRealm = userRealms[0];
                }
            }
            this.$el.html(
                $(this.template({
                    realms: sharedModels.realms.toJSON(),
                    defaultRealm: defaultRealm
                }))
            );

            var qe = this.$('.quest-edit-name');
            this.$('.modal').modal().on('shown', function () {
                qe.focus();
            });
            this.$('.modal').modal().on('hidden', function (e) {
                if (!$(e.target).hasClass('modal')) {
                    // modal includes items with tooltip, which can fire "hidden" too,
                    // and these events bubble up DOM tree, ending here
                    return;
                }
                that.remove();
            });

            this.$('.btn-group').button();

            this.$('.icon-spinner').hide();
            this.submitted = false;
            this.validate();

            this.$('.quest-edit-description').autosize({ append: "\n" });
        },

        submit: function() {
            if (!this.enabled) {
                return;
            }

            var model_params = {
                name: this.getName(),
                realm: this.getRealm()
            };

            var description = this.getDescription();
            if (description) {
                model_params.description = description;
            }

            var tags = this.getTags();
            if (tags) {
                model_params.tags = tags;
            }

            var model = new QuestModel();
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
            Backbone.trigger('pp:quest-add', model);
            this.$('.quest-add-modal').modal('hide');
        }
    });
});
