pp.models.EventCollection = pp.Collection.WithCgiAndPager.extend({
    baseUrl: '/api/event',
    cgi: ['limit', 'offset'],
    model: pp.models.Event
});
