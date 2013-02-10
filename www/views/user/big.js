pp.views.UserBig = pp.View.Common.extend({
    // left column of the dashboard page
    t: 'user-big',

    features: ['tooltip'],

    serialize: function () {
        return this.model.toJSON();
    },
});
