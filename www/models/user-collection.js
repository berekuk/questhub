pp.models.UserCollection = Backbone.Collection.extend({
    url: '/api/users',
    model: pp.models.Quest
});
