define([
    'models/proto/paged-collection', 'models/quest'
], function (Parent, Quest) {
    return Parent.extend({
        defaultCgi: ['comment_count=1'],
        baseUrl: '/api/quest',
        cgi: ['user', 'status', 'limit', 'offset', 'sort', 'order', 'unclaimed', 'tags'],
        model: Quest
    });
});
