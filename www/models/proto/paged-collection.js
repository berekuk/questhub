// see models/user-collection.js for implementation example
define([
    'backbone', 'underscore'
], function (Backbone, _) {
    return Backbone.Collection.extend({

        // all implementations should support at least 'limit' and 'offset'
        // if you override cgi, don't forget about it!
        cgi: ['limit', 'offset'],

        // baseUrl is required

        defaultCgi: [],

        url: function() {
            var url = this.baseUrl;
            var cgi = this.defaultCgi.slice(0); // clone

            _.each(this.cgi, function (key) {
                if (this.options[key]) {
                    cgi.push(key + '=' + this.options[key]);
                }
            }, this);

            if (cgi.length) {
                url += '?' + cgi.join('&');
            }
            return url;
        },

        initialize: function(model, args) {
            this.options = args || {};
            if (this.options.limit) this.options.limit++; // always ask for one more
            this.gotMore = true; // optimistic :)
        },

        // copied and adapted from Backbone.Collection.fetch
        // see http://documentcloud.github.com/backbone/docs/backbone.html#section-104
        // we have to do it manually, because we want to know the size of resp, and ignore the last item
        fetch: function(options) {
            options = options ? _.clone(options) : {};
            if (options.parse === void 0) options.parse = true;
            var success = options.success;
            options.success = function(collection, resp, options) {
                if (collection.options.limit) {
                    collection.gotMore = (resp.length >= collection.options.limit);
                    if (collection.gotMore) {
                        resp.pop(); // always ignore last item, we asked for it only for the sake of knowing if there's more
                    }
                }
                else {
                    collection.gotMore = false; // there was no limit, so we got everything there is
                }

                var method = options.update ? 'update' : 'reset';
                collection[method](resp, options);
                if (success) {
                    success(collection, resp, options);
                }
            };
            return this.sync('read', this, options);
        },

        // pager
        // supports { success: ..., error: ... } as a second parameter
        fetchMore: function (count, options) {
            this.options.offset = this.length;
            this.options.limit = count + 1;

            if (!options) {
                options = {};
            }

            options.update = true;
            options.remove = false;

            return this.fetch(options);
        },
    });
});
