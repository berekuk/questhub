pp.views.EventCollection = Backbone.View.extend({
    // this is a copy-paste of views/quest/collection.js
    // need to learn a better way of rendering collections, or move this code to the common class

    tag: 'div',

    template: _.template($('#template-event-collection').text()),

    initialize: function () {
        this.options.events.on('reset', this.onReset, this);
        this.options.events.on('update', this.render, this);
        this.options.events.on('add', this.onAdd, this);
        this.render();
    },

    render: function (collection) {
        this.$el.html(this.template());
        return this;
    },

    onAdd: function (ev) {
        var view = new pp.views.Event({model: ev});
        var l = this.$el.find('.events-list');
        l.show(); // see also: https://github.com/berekuk/play-perl/issues/61
        l.append(view.render().el);
    },

    onReset: function () {
        this.options.events.each(this.onAdd, this);
    }
});
