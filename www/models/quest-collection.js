pp.models.QuestCollection = Backbone.Collection.extend({

    url: '/api/quests',
    model: pp.models.Quest

});
