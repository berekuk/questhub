pp.models.UserCollection = Backbone.Collection.extend({

    url: function() {
        console.log(this);
        var url = '/api/user';
        var cgi = [];
        if (this.options.sort_key) {
            cgi.push('sort=' + this.options.sort_key);
        }
        if (this.options.order) {
            cgi.push('order=' + this.options.order);
        }
        if (cgi.length) {
            url += '?' + cgi.join('&');
        }
        return url;
    },

    initialize: function(model, args) {
        this.options = args;
    },

    model: pp.models.AnotherUser
});
