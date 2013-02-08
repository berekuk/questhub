pp.models.EventCollection = Backbone.Collection.extend({
    url: '/api/event',
    model: pp.models.Event
});
