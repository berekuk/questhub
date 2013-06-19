define([
    'backbone',
    'models/proto/paged-collection', 'models/event'
], function (Backbone, Parent, Event) {
    return Parent.extend({
        baseUrl: '/api/event',
        cgi: ['limit', 'offset', 'realm', 'for'],
        model: Event
    });
});
