pp.views.EventCollection = Backbone.View.extend({
    // this is a copy-paste of views/quest/collection.js
    // need to learn a better way of rendering collections, or move this code to the common class

    tag: 'div',

    template: _.template($('#template-event-collection').text()),

    initialize: function () {
        this.collection.on('reset', this.onReset, this);
        this.collection.on('update', this.render, this);
        this.collection.on('add', this.onAdd, this);
        this.render();
    },

    render: function () {
        this.$el.html(this.template());
        return this;
    },

    onAdd: function (ev) {
        var view = new pp.views.EventBox({model: ev});
        var l = this.$el.find('.events-list');
        l.show(); // see also: https://github.com/berekuk/play-perl/issues/61
        view.render();
        l.append(view.el);
    },

    onReset: function () {
        this.collection.each(this.onAdd, this);
    }
});
