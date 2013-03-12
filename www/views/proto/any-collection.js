/*
 * Any collection view consisting of arbitrary list of subviews
 *
 * options:
 *   generateItem(model): function generating one item subview
 *   listSelector: css selector specifying the div to which subviews will be appended (or prepended, or whatever - see 'insertMethod')
 *
 * Note that this view defines 'afterInitialize' and 'afterRender'. Sorry, future me.
 */
define([
    'backbone', 'underscore', 'views/proto/common'
], function (Backbone, _, Common) {
    return Common.extend({

        activated: false,

        afterInitialize: function () {
            this.listenTo(this.collection, 'reset', this.activate);
            this.listenTo(this.collection, 'add', this.onAdd);
            this.listenTo(this.collection, 'remove', this.render); // TODO: optimize
        },

        itemSubviews: [],

        // can be overriden if 'append' strategy doesn't fit you
        insertOne: function (el, options) {
            if (options && options.prepend) {
                // this branch is not used in any real code, but still supported for the consistency with proto-paged.js implementation
                this.$(this.listSelector).prepend(el);
            }
            else {
                this.$(this.listSelector).append(el);
            }
        },

        removeItemSubviews: function () {
            _.each(this.itemSubviews, function (subview) {
                subview.remove();
            });
            this.itemSubviews = [];
        },

        afterRender: function () {
            this.removeItemSubviews();
            if (this.collection.length) {
                this.$(this.listSelector).show(); // collection table is hidden initially - see https://github.com/berekuk/play-perl/issues/61
            }
            this.collection.each(this.renderOne, this);
        },

        generateItem: function (model) {
            alert('not implemented');
        },

        renderOne: function(model, options) {
            var view = this.generateItem(model);
            this.itemSubviews.push(view);
            this.insertOne(view.render().el, options);
        },

        onAdd: function (model, collection, options) {
            this.$(this.listSelector).show();
            this.renderOne(model, options); // possible options: { prepend: true }
        },

        remove: function () {
            this.removeItemSubviews();
            Common.prototype.remove.apply(this, arguments);
        }
    });
});
