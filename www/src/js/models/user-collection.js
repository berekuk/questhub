define([
    'models/proto/paged-collection', 'models/another-user'
], function (Parent, AnotherUser) {
    return Parent.extend({

        cgi: ['sort', 'order', 'limit', 'offset', 'realm'],

        baseUrl: '/api/user',

        model: AnotherUser
    });
});
