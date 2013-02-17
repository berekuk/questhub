pp.models.QuestCollection = pp.Collection.WithCgiAndPager.extend({

    defaultCgi: ['comment_count=1'],

    baseUrl: '/api/quest',

    opt2cgi: {
        'user': 'user',
        'status': 'status',
        'limit': 'limit',
        'offset': 'offset'
    },

    model: pp.models.Quest
});
