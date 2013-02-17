pp.models.UserCollection = pp.Collection.WithCgiAndPager.extend({

    opt2cgi: {
        'sort_key': 'sort',
        'order': 'order',
        'limit': 'limit',
        'offset': 'offset'
    },

    baseUrl: '/api/user',

    model: pp.models.AnotherUser
});
