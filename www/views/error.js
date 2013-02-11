pp.views.Error = pp.View.Common.extend({

    t: 'error',

    serialize: function () {
        return { error: this.options.error };
    }
});
