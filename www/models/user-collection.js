pp.models.UserCollection = pp.Collection.WithCgiAndPager.extend({

    cgi: ['sort', 'order', 'limit', 'offset'],

    baseUrl: '/api/user',

    model: pp.models.AnotherUser
});
