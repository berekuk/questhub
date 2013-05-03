/* Common questhub view.
 * It declares render() itself, you need to declare serialize() instead of render.
 * If you want to do some more work on render(), define afterRender().
 *
 * It also declares initialize().
 * If you want to do some more work on render(), define afterInitialize().
 *
 * options:
 *   t: 'blah' - use '#template-blah' template
 *   selfRender: this flag causes initialize() to call render()
 *   serialize: should prepare params for the template; defaults to self.model.toJSON(), or {} if model is not defined
 *   features: array with features that should be enabled in html after rendering; possible values: ['timeago', 'tooltip']
 *   subviews: events-style hash with subviews; see assign pattern in http://ianstormtaylor.com/assigning-backbone-subviews-made-even-cleaner/
 *   activated: if false, turn render() into a null operation until someone calls activate(); also, don't initialize subviews until activation
 *
 * subviews usage example:
 *   subviews: {
 *     '.foo-item': function() { return new Foo() },
 *     '.bar-item': 'barSubview',
 *   },
 *   barSubview: function() {
 *      return new Bar(); // will be called only once and cached
 *   }
 *
 * Note that this class overrides remove(), calling remove() for all subviews for you. Die, zombies.
*/
define([
    'backbone', 'underscore',
    'views/proto/base',
    'jquery.timeago', 'bootstrap' // for features
], function (Backbone, _, Base) {
    "use strict";
    return Base.extend({

        // TODO - detect 't' default value from the class name somehow? is it possible in JS?

        initialize: function () {
            Base.prototype.initialize.apply(this, arguments);

            if (this.activated) {
                this.initSubviews();
            }
            this.afterInitialize();

            if (this.selfRender) {
                this.render();
            }
        },

        initSubviews: function () {
            if (this._subviewInstances) {
                // this was a warning situation in the past, but now views/explore.js legitimately re-initializes subviews
                //            console.log('initSubviews is called twice!');
            }
            this._subviewInstances = {};
            var that = this;
            _.each(_.keys(this.subviews), function(key) {
                that.subview(key); // will perform the lazy init
            });
        },

        // get a subview from cache, lazily instantiate it if necessary
        subview: function (key) {
            if (!this._subviewInstances[key]) {
                var value = this.subviews[key];

                var method = value;
                if (!_.isFunction(method)) method = this[value];
                if (!method) throw new Error('Method "' + value + '" does not exist');
                method = _.bind(method, this);
                var subview = method();
                this._subviewInstances[key] = subview;
            }
            return this._subviewInstances[key];
        },

        afterInitialize: function () {
        },

        serialize: function () {
            if (this.model) {
                return this.model.toJSON();
            }
            else {
                return {};
            }
        },

        features: [],

        subviews: {},

        activated: true,

        activate: function () {
            if (!this.activated) {
                this.activated = true;
                this.initSubviews();
            }
            this.render();
        },

        render: function () {
            if (!this.activated) {
                return;
            }

            var params = this.serialize();
            params.partial = this.partial;
            this.$el.html(this.template(params));

            // TODO - enable all features by default?
            // how much overhead would that create?
            var that = this;
            _.each(this.features, function(feature) {
                if (feature == 'timeago') {
                    that.$('time.timeago').timeago();
                }
                else if (feature == 'tooltip') {
                    that.$('[data-toggle=tooltip]').tooltip();
                }
                else {
                    console.log("unknown feature: " + feature);
                }
            });

            this.afterRender();

            _.each(_.keys(this._subviewInstances), function(key) {
                var subview = that._subviewInstances[key];

                subview.setElement(that.$(key)).render();
            });

            return this;
        },

        afterRender: function () {
        },

        remove: function () {
            var that = this;
            // _subviewInstances can be undefined if view was never activated
            if (this._subviewInstances) {
                _.each(_.keys(this._subviewInstances), function(key) {
                    var subview = that._subviewInstances[key];
                    subview.remove();
                });
            }
            Base.prototype.remove.apply(this, arguments);
        }
    });
});
