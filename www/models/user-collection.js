pp.models.UserCollection = Backbone.Collection.extend({

    _opt2cgi: {
        'sort_key': 'sort',
        'order': 'order',
        'limit': 'limit',
        'offset': 'offset'
    },

    url: function() {
        var url = '/api/user';
        var cgi = [];

        _.each(this._opt2cgi, function (cgiKey, optKey) {
            if (this.options[optKey]) {
                cgi.push(cgiKey + '=' + this.options[optKey]);
            }
        }, this);

        if (cgi.length) {
            url += '?' + cgi.join('&');
        }
        console.log(url);
        return url;
    },

    initialize: function(model, args) {
        this.options = args;
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

    model: pp.models.AnotherUser
});
