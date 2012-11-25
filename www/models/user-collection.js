pp.models.UserCollection = Backbone.Collection.extend({
    url: '/api/user',
    model: pp.models.AnotherUser
});
