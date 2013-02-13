pp.models.UserCollection = Backbone.Collection.extend({
    url: '/api/user',

    initialize: function(models, args) {
        this.url = function() {
            var url = '/api/user';
            var cgi = [];
            if (args.sort_key) {
                cgi.push('sort=' + args.sort_key);
            }
            if (args.order) {
                cgi.push('order=' + args.order);
            }
            if (cgi.length) {
                url += '?' + cgi.join('&');
            }
            return url;
        };
    },

    model: pp.models.AnotherUser
});
