// see models/user-collection.js for implementation example
pp.Collection.WithCgiAndPager = Backbone.Collection.extend({

    // all implementations should support at least 'limit' and 'offset'
    // if you override opt2cgi, don't forget about it!
    opt2cgi: {
        'limit': 'limit',
        'offset': 'offset'
    },

    // baseUrl is required

    defaultCgi: [],

    url: function() {
        var url = this.baseUrl;
        var cgi = this.defaultCgi.slice(0); // clone

        _.each(this.opt2cgi, function (cgiKey, optKey) {
            if (this.options[optKey]) {
                cgi.push(cgiKey + '=' + this.options[optKey]);
            }
        }, this);

        if (cgi.length) {
            url += '?' + cgi.join('&');
        }
        return url;
    },

    initialize: function(model, args) {
        this.options = args || {};
    },

    // pager
    // supports { success: ..., error: ... } as a second parameter
    fetchMore: function (count, options) {
        this.options.offset = this.length;
        this.options.limit = count;

        if (!options) {
            options = {};
        }
        options.update = true;
        options.remove = false;
        this.fetch(options);
    },

});
