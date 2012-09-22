pp.models.Quest = Backbone.Collection.extend({

    urlRoot: '/api/quest/'

});

pp.models.QuestCollection = Backbone.Collection.extend({

    url: '/api/quests',
    model: pp.models.Quest

});
