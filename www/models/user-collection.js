pp.models.UserCollection = Backbone.Collection.extend({

    url: function() {
        var url = '/api/user';
        var cgi = [];
        if (this.options.sort_key) {
            cgi.push('sort=' + this.options.sort_key);
        }
        if (this.options.order) {
            cgi.push('order=' + this.options.order);
        }
        if (this.options.limit) {
            cgi.push('limit=' + this.options.limit);
        }
        if (cgi.length) {
            url += '?' + cgi.join('&');
        }
        return url;
    },

    initialize: function(model, args) {
        this.options = args;
    },

    fetchMore: function (count) {
        this.options.limit += count;
        this.fetch();
    },

    model: pp.models.AnotherUser
});
