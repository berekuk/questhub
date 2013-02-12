pp.View.Base = Backbone.View.extend({
    partial: {
        user: _.template($('#partial-user').text()),
        edit_tools: _.template($('#partial-edit-tools').text())
    },

    initialize: function () {
        this.listenTo(Backbone, 'pp:logviews', function () {
            console.log(this);
        });
    }
});

/* Common play-perl view.
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
 *     '.foo-item': function() { return new pp.views.Foo() },
 *     '.bar-item': 'barSubview',
 *   },
 *   barSubview: function() {
 *      return new pp.views.Bar(); // will be called only once and cached
 *   }
 *
 * Note that this class overrides remove(), calling remove() for all subviews for you. Die, zombies.
*/
pp.View.Common = pp.View.Base.extend({

    // TODO - detect 't' default value from the class name somehow? is it possible in JS?

    initialize: function () {
        pp.View.Base.prototype.initialize.apply(this, arguments);

        this.template = _.template($('#template-' + this.t).text());

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
            alert('initSubviews is called twice!');
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
            this.render();
        }
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
                that.$el.find('time.timeago').timeago();
            }
            else if (feature == 'tooltip') {
                that.$el.find('[data-toggle=tooltip]').tooltip();
            } else {
                console.log("unknown feature: " + feature);
            }
        });

        this.afterRender();

        _.each(_.keys(this._subviewInstances), function(key) {
            var subview = that._subviewInstances[key];

            subview.setElement(that.$el.find(key)).render();
        });

        return this;
    },

    afterRender: function () {
    },

    remove: function () {
        var that = this;
        _.each(_.keys(this._subviewInstances), function(key) {
            var subview = that._subviewInstances[key];
            subview.remove();
        });
        pp.View.Base.prototype.remove.apply(this, arguments);
    }
});

/*
 * Any collection view consisting of arbitrary list of subviews
 *
 * options:
 *   generateItem(model): function generating one item subview
 *   listSelector: css selector specifying the div to which subviews will be appended
 *
 * Note that this view defines 'afterInitialize' and 'afterRender'. Sorry, future me.
 */
pp.View.AnyCollection = pp.View.Common.extend({

    activated: false,

    afterInitialize: function () {
        this.listenTo(this.collection, 'reset', this.activate);
        this.listenTo(this.collection, 'add', this.activate); // TODO: optimize
        this.listenTo(this.collection, 'remove', this.activate); // TODO: optimize
    },

    itemSubviews: [],

    removeItemSubviews: function () {
        console.log('removeItemSubviews ' + this.itemSubviews);
        _.each(this.itemSubviews, function (subview) {
            subview.remove();
        });
        this.itemSubviews = [];
    },

    afterRender: function () {
        console.log('afterRender');
        this.removeItemSubviews();
        this.collection.each(this.renderOne, this);
    },

    generateItem: function (model) {
        alert('not implemented');
    },

    renderOne: function(model) {
        var view = this.generateItem(model);
        this.itemSubviews.push(view);
        var list = this.$el.find(this.listSelector);
        list.show(); // collection table is hidden initially - see https://github.com/berekuk/play-perl/issues/61
        list.append(view.render().el);
    },

    onAdd: function () {
        this.render();
    },

    onReset: function () {
        this.render();
    },

    // copy-paste from pp.View.Common
    remove: function () {
        this.removeItemSubviews();
        pp.View.Common.prototype.remove.apply(this, arguments);
    }
});
