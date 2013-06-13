// left column of the dashboard page
define([
    'underscore',
    'views/proto/common',
    'models/current-user',
    'views/quest/add',
    'text!templates/user-big.html'
], function (_, Common, currentUser, QuestAdd, html) {
    return Common.extend({
        template: _.template(html),

        realm: function () {
            return this.options.realm;
        },

        events: {
            'click .quest-add-dialog': 'newQuestDialog',
            'click .settings': 'settingsDialog'
        },

        settingsDialog: function () {
            Backbone.trigger('pp:settings-dialog');
        },

        serialize: function () {
            var params = this.model.toJSON();

            var currentLogin = currentUser.get('login');
            params.my = (currentLogin && currentLogin == this.model.get('login'));
            params.realm = this.realm();
            return params;
        },

        newQuestDialog: function() {
            var questAdd = new QuestAdd({
                collection: this.options.open_quests.collection
            });
            this.$el.append(questAdd.$el); // FIXME - DOM memory leak
            ga('send', 'event', 'quest', 'new-dialog');
        },

        features: ['tooltip'],
    });
});
