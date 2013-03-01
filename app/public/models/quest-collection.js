pp.models.QuestCollection = pp.Collection.WithCgiAndPager.extend({
    defaultCgi: ['comment_count=1'],
    baseUrl: '/api/quest',
    cgi: ['user', 'status', 'limit', 'offset', 'sort', 'order', 'unclaimed'],
    model: pp.models.Quest
});
