pp.View.Base = Backbone.View.extend({
    partial: {
        user: _.template($('#partial-user').text())
    }
});

// common play-perl view
// it declares render() itself
// options:
//   t: 'blah' - use '#template-blah' template
//   selfRender: this flag causes initialize() to call render()
//   serialize: should prepare params for the template
//   features: array with features that should be enabled in html after rendering; possible values: ['timeago', 'tooltip']
//   afterRender: optional render() method modifier
pp.View.Common = pp.View.Base.extend({

    // TODO - detect 't' default value from the class name somehow? is it possible in JS?

    initialize: function () {
        this.template = _.template($('#template-' + this.t).text());
        if (this.selfRender) {
            this.render();
        }
    },

    serialize: function () {
        return {};
    },

    features: [],

    render: function () {
        var params = this.serialize();
        params.partial = this.partial;
        this.$el.html(this.template(params));

        // TODO - enable all features by default?
        // how much overhead would that create?
        var that = this;
        _.each(this.features, function(feature) {
            if (feature == 'timeago') {
                that.$el.find('time.timeago').timeago();
            }
            else if (feature == 'tooltip') {
                that.$el.find('[data-toggle=tooltip]').tooltip();
            } else {
                console.log("unknown feature: " + feature);
            }
        });

        this.afterRender();

        return this;
    },

    afterRender: function () {
    }

});
