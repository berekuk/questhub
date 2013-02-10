pp.View.Base = Backbone.View.extend({
    partial: {
        user: _.template($('#partial-user').text())
    }
});

// template without parameters, and nothing else
// usage:
//   pp.views.Blah = pp.view.Simple.extend({ t: 'blah' })
// 'selfRender' flag causes initialize() to call render()
pp.View.Simple = pp.View.Base.extend({
    initialize: function() {
        console.log('initialize, ' + this.t);
        this.template = _.template($('#template-' + this.t).text());
        if (this.selfRender) {
            this.render();
        }
    },
    render: function () {
        console.log('render');
        this.$el.html(this.template());
        return this;
    }
});
