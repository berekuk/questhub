// TODO: check if we need to remove this view on close to avoid memory leak
pp.views.Notify = pp.View.Common.extend({

    t: 'notify',

    serialize: function () {
        return this.options;
    }
});
