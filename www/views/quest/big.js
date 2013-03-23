define([
    'underscore',
    'backbone',
    'views/proto/common',
    'views/like',
    'models/current-user',
    'bootbox',
    'text!templates/quest-big.html'
], function (_, Backbone, Common, Like, currentUser, bootbox, html) {
    'use strict';
    return Common.extend({
        template: _.template(html),

        events: {
            "click .quest-close": "close",
            "click .quest-abandon": "abandon",
            "click .quest-leave": "leave",
            "click .quest-join": "join",
            "click .quest-resurrect": "resurrect",
            "click .quest-reopen": "reopen",
            "click .delete": "destroy",
            "click .edit": "edit",
            "keypress .quest-edit": "updateOnEnter",
            "blur .quest-edit": "closeEdit"
        },

        subviews: {
            '.likes': function () {
                return new Like({ model: this.model });
            }
        },

        afterInitialize: function () {
            this.listenTo(this.model, 'change', this.render);
        },

        close: function () {
            this.model.close();
        },

        abandon: function () {
            this.model.abandon();
        },

        leave: function () {
            this.model.leave();
        },

        join: function () {
            this.model.join();
        },

        resurrect: function () {
            this.model.resurrect();
        },

        reopen: function () {
            this.model.reopen();
        },

        edit: function () {
            if (!this.isOwned()) {
                return;
            }
            this.$('.quest-edit').show();
            this.$('.quest-title').hide();
            this.$('.quest-edit').focus();
        },

        updateOnEnter: function (e) {
            if (e.keyCode == 13) this.closeEdit();
        },

        closeEdit: function() {
            var value = this.$('.quest-edit').val();
            if (!value) {
                return;
            }
            this.model.save({ name: value });
            this.$('.quest-edit').hide();
            this.$('.quest-title').show();
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

        isOwned: function () {
            return (currentUser.get('login') == this.model.get('user'));
        },

        serialize: function () {
            var params = this.model.serialize();
            // TODO - should we move this to model?
            params.currentUser = currentUser.get('login');
            params.my = this.isOwned();
            if (!params.likes) {
                params.likes = [];
            }
            return params;
        },
    });
});
