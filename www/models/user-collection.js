define([
    'models/proto/paged-collection', 'models/another-user'
], function (Parent, AnotherUser) {
    return Parent.extend({

        cgi: ['sort', 'order', 'limit', 'offset'],

        baseUrl: '/api/user',

        model: AnotherUser
    });
});
