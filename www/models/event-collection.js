define([
    'backbone',
    'models/proto/paged-collection', 'models/event'
], function (Backbone, Parent, Event) {
    return Parent.extend({
        baseUrl: '/api/event',
        cgi: ['limit', 'offset', 'types'],
        model: Event,
        setTypes: function(types) {
            this.options.types = types;
            this.options.offset = 0;
            this.options.limit = 101;
            this.fetch(this.options);
        }
    });
});
