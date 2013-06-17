define([
    'underscore', 'jquery',
    'backbone',
    'views/proto/common',
    'views/quest/like',
    'models/current-user',
    'bootbox',
    'text!templates/quest-big.html'
], function (_, $, Backbone, Common, Like, currentUser, bootbox, html) {
    'use strict';
    return Common.extend({
        template: _.template(html),

        events: {
            "click .quest-join": "join",
            "click .delete": "destroy",
            "click .edit": "startEdit",
            "click button.save": "saveEdit",
            "keyup input": "edit",
            "keyup [name=description]": "edit",
            'mouseenter': function (e) {
                this.subview('.likes-subview').showButton();
            },
            'mouseleave': function (e) {
                this.subview('.likes-subview').hideButton();
            }
        },

        subviews: {
            '.likes-subview': function () {
                return new Like({
                    model: this.model,
                    hidden: true
                });
            }
        },

        afterInitialize: function () {
            this.listenTo(this.model, 'change', this.render);
        },

        join: function () {
            this.model.join();
        },

        startEdit: function () {
            if (!this.model.isOwned()) {
                return;
            }
            this.$('.quest-big-edit').show();

            this.backup = _.clone(this.model.attributes);

            var tags = this.model.get('tags') || [];
            this.$('[name=tags]').val(tags.join(', '));
            this.$('[name=name]').val(this.model.get('name'));
            this.$('[name=description]').val(this.model.get('description')).trigger('autosize');
            this.validateForm();

            this.$('.quest-big-editable').hide();
            this.$('[name=name]').focus();
        },

        // check if edit form is valid, and also highlight invalid fiels appropriately
        validateForm: function () {
            var ok = true;
            if (this.$('[name=name]').val().length) {
                this.$('[name=name]').parent().removeClass('error');
            }
            else {
                this.$('[name=name]').parent().addClass('error');
                ok = false;
            }

              var cg = this.$('[name=tags]').parent(); // control-group
            if (this.model.validateTagline(cg.find('input').val())) {
                cg.removeClass('error');
                cg.find('input').tooltip('hide');
            }
            else {
                if (!cg.hasClass('error')) {
                    cg.addClass('error');

                    // copy-pasted from views/quest/add, TODO - refactor
                    var oldFocus = $(':focus');
                    cg.find('input').tooltip('show');
                    $(oldFocus).focus();
                }
                ok = false;
            }

            if (ok) {
                this.$('button.save').removeClass('disabled');
            }
            else {
                this.$('button.save').addClass('disabled');
            }
            return ok;
        },

        edit: function (e) {
            var target = $(e.target);
            if (this.validateForm() && e.which == 13 && target.is('input')) {
                this.saveEdit();
            }
            else if (e.which == 27) {
                this.closeEdit();
            }
            else if (target.is('textarea')) {
                this.$('.comment-preview').html(markdown(text, this.options.realm));
            }
        },

        closeEdit: function() {
            this.$('.quest-big-edit').hide();
            this.$('.quest-big-editable').show();
        },

        saveEdit: function () {
            // so, we're using DOM data to cache validation status... this is a slippery slope.
            if (this.$('button.save').hasClass('disabled')) {
                return;
            }

            // form is validated already by edit() method
            var name = this.$('[name=name]').val();
            var description = this.$('[name=description]').val();
            var tagline = this.$('[name=tags]').val();

            this.model.save({
                name: name,
                description: description,
                tags: this.model.tagline2tags(tagline)
            });
            this.closeEdit();
        },

        destroy: function () {
            var that = this;
            bootbox.confirm("Quest and all comments will be destroyed permanently. Are you sure?", function(result) {
                if (result) {
                    that.model.destroy({
                        success: function(model, response) {
                            Backbone.trigger('pp:navigate', '/', { trigger: true });
                        },
                    });
                }
            });
        },

        serialize: function () {
            var params = this.model.serialize();
            params.currentUser = currentUser.get('login');
            params.meGusta = _.contains(params.likes || [], params.currentUser);
            params.showStatus = true;
            return params;
        },

        afterRender: function () {
            this.$('[name=description]').autosize({ append: "\n" });
        },

        features: ['tooltip', 'timeago']
    });
});
