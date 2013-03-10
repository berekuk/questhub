pp.View.Base = Backbone.View.extend({
    partial: {
        user: _.template($('#partial-user').text()),
        quest_labels: _.template($('#partial-quest-labels').text()),
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
        pp.View.Base.prototype.remove.apply(this, arguments);
    }
});

/*
 * Any collection view consisting of arbitrary list of subviews
 *
 * options:
 *   generateItem(model): function generating one item subview
 *   listSelector: css selector specifying the div to which subviews will be appended (or prepended, or whatever - see 'insertMethod')
 *
 * Note that this view defines 'afterInitialize' and 'afterRender'. Sorry, future me.
 */
pp.View.AnyCollection = pp.View.Common.extend({

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

    // copy-paste from pp.View.Common
    remove: function () {
        this.removeItemSubviews();
        pp.View.Common.prototype.remove.apply(this, arguments);
    }
});
pp.views.App = pp.View.Base.extend({

    initialize: function () {
        this.currentUser = new pp.views.CurrentUser();
        this.currentUser.setElement(this.$el.find('.current-user-box'));

        this._markdownConverter = new Markdown.getSanitizingConverter();
        this._markdownConverter.hooks.chain('postSpanGamut', function (text) {
            text = text.replace(/\b(\w+(?:::\w+)+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))/g, '<a href="http://metacpan.org/module/\$1">\$1</a>');
            text = text.replace(/\bcpan:(\w+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))/g, '<a href="http://metacpan.org/module/\$1">\$1</a>');
            return text;
        });
    },

    notify: function (type, message) {
        this.$('.app-view-container').prepend(
            new pp.views.Notify({
                type: type,
                message: message
            }).render().el
        );
    },

    markdownToHtml: function (markdown) {
        return this._markdownConverter.makeHtml(markdown);
    },

    setPageView: function (page) {

        // the explanation of pattern can be found in this article: http://lostechies.com/derickbailey/2011/09/15/zombies-run-managing-page-transitions-in-backbone-apps/
        // (note that the article is dated - it's pre-0.9.2, Backbone didn't have .listenTo() back then
        if (this._page) {
            this._page.remove(); // TODO - should we remove all subviews too?
        }
        this._page = page;
        this.$('.app-view-container').append(page.$el);

        // (THIS COMMENT IS DEPRECATED. EVERYTHING HAS CHANGED.)
        // we don't call page.render() - our pages render themselves, but sometimes they do it in delayed fashion
        // (i.e., wait for user model to fetch first, and sometimes navigate to the different page based on that)
    }
});
// TODO: check if we need to remove this view on close to avoid memory leak
pp.views.Notify = pp.View.Common.extend({

    t: 'notify',

    serialize: function () {
        return this.options;
    }
});
pp.views.Progress = pp.View.Common.extend({
    t: 'progress',

    on: function () {
        this.off();

        var that = this;
        this.progressPromise = window.setTimeout(function () {
            that.$('.icon-spinner').show();
        }, 500);
    },

    off: function () {
        this.$('.icon-spinner').hide();
        if (this.progressPromise) {
            window.clearTimeout(this.progressPromise);
        }
    },

});
// collection which shows first N items, and then others can be fetched by clicking "show more" button
// your view is going to need:
// 1) template with a clickable '.show-more' element and with '.progress-spin' element
// 2) listSelector, just like in AnyCollection
// 3) generateItem, just like in AnyCollection
//
// This collection depends on pp.views.Progress, which depends on pp.View.Common... so it lives in a separate from proto.js file.
pp.View.PagedCollection = pp.View.AnyCollection.extend({
    events: {
        "click .show-more": "showMore",
    },

    subviews: {
        '.progress-spin': function () {
            return new pp.views.Progress();
        },
    },

    insertOne: function (el, options) {
        if (options && options.prepend) {
            this.$(this.listSelector).prepend(el);
        }
        else {
            this.$('.show-more').before(el);

        }
    },

    activated: true,

    pageSize: 100,

    noProgress: function () {
        this.$('.show-more').toggle(this.collection.gotMore);
        this.$('.show-more').removeClass('disabled');
        this.subview('.progress-spin').off();
    },

    afterInitialize: function () {
        pp.View.AnyCollection.prototype.afterInitialize.apply(this, arguments);

        this.subview('.progress-spin').on(); // app.js fetches the collection for the first time immediately

        this.collection.once('reset', this.noProgress, this);
        this.listenTo(this.collection, 'error', this.noProgress);
        this.render();
    },

    showMore: function () {
        var that = this;

        this.$('.show-more').addClass('disabled');
        this.subview('.progress-spin').on();

        this.collection.fetchMore(this.pageSize, {
            error: function (collection, response) {
                pp.app.onError(undefined, response);
            }
        }).always(function () {
            that.noProgress();
        });
    },

    afterRender: function () {
        pp.View.AnyCollection.prototype.afterRender.apply(this, arguments);
        this.$el.find('[data-toggle=tooltip]').tooltip('show');
    }

});
pp.views.Dashboard = pp.View.Common.extend({

    t: 'dashboard',

    activated: false,

    events: {
        "click .quest-add-dialog": "newQuestDialog",
    },

    subviews: {
        '.user': function () {
            return new pp.views.UserBig({
                model: this.model
            }); // TODO - fetch or not?
        },
        '.open-quests': function () { return this.createQuestSubview('open') },
        '.closed-quests': function () { return this.createQuestSubview('closed') },
        '.abandoned-quests': function () { return this.createQuestSubview('abandoned', 5) }
    },

    createQuestSubview: function (st, limit) {
        if (limit === undefined) {
            limit = 30;
        }
        var login = this.model.get('login');
        var collection = new pp.models.QuestCollection([], {
           'user': login,
           'status': st,
            'limit': limit
        });
        collection.comparator = function(m1, m2) {
            if (m1.id > m2.id) return -1; // before
            if (m2.id > m1.id) return 1; // after
            return 0; // equal
        };
        collection.fetch();

        return new pp.views.QuestCollection({
            collection: collection
        });
    },

    afterRender: function () {
        var currentUser = pp.app.user.get('login');
        if (currentUser && currentUser == this.model.get('login')) {
            this.$('.new-quest').show();
        }
    },

    newQuestDialog: function() {
        var questAdd = new pp.views.QuestAdd({
          collection: this.subview('.open-quests').collection
        });
        this.$el.append(questAdd.$el);
    },
});
pp.views.Explore = pp.View.Common.extend({
    t: 'explore',

    events: {
        'click ul.explore-nav a': 'switchTab',
    },

    subviews: {
        '.explore-tab-content': 'tabSubview'
    },

    tab: 'latest',
    activated: false,

    afterInitialize: function () {
        _.bindAll(this);
    },

    name2options: {
        'latest': { order: 'desc' },
        'unclaimed': { unclaimed: 1, sort: 'leaderboard' },
        'open': { status: 'open', sort: 'leaderboard' },
        'closed': { status: 'closed', sort: 'leaderboard' }
    },

    tabSubview: function () {
        return this.createSubview(this.name2options[this.tab]);
    },

    createSubview: function (options) {

        options.limit = 100;
        var collection = new pp.models.QuestCollection([], options);

        // duplicates server-side sorting logic!
        if (options.sort && options.sort == 'leaderboard') {
            collection.comparator = function(m1, m2) {
                if (m1.like_count() > m2.like_count()) return -1; // before
                if (m2.like_count() > m1.like_count()) return 1; // after

                if (m1.comment_count() > m2.comment_count()) return -1;
                if (m2.comment_count() > m1.comment_count()) return 1;
                return 0; // equal
            };
        }
        collection.fetch();
        if (options.sort) {
            collection.sort();
        }

        return new pp.views.QuestCollection({
            collection: collection,
            showAuthor: true
        });
    },

    switchTab: function (e) {
        var tab = $(e.target).attr('data-explore-tab');
        this.switchTabByName(tab);
        pp.app.router.navigate('/explore/' + tab);
    },

    switchTabByName: function(tab) {
        this.tab = tab;
        this.initSubviews(); // recreate tab subview
        this.render();
    },

    afterRender: function () {
        this.$('[data-explore-tab=' + this.tab + ']').parent().addClass('active');
    }
});
pp.views.Home = pp.View.Common.extend({
    t: 'home',
    selfRender: true,

    events: {
        'click .login-with-persona': 'personaLogin',
    },

    subviews: {
        '.signin': function () { return new pp.views.Signin(); }
    },

    afterInitialize: function () {
        this.listenTo(pp.app.user, 'change:registered', function () {
            pp.app.router.navigate("/", { trigger: true, replace: true });
        });
    },

    personaLogin: function () {
        navigator.id.request();
    }
});
pp.views.QuestAdd = pp.View.Base.extend({
    events: {
        'click .quest-add': 'submit',
        'click .quest-type-select button': 'setType',
        'keyup [name=name]': 'validate'
    },

    template: _.template($('#template-quest-add').text()),

    initialize: function() {
        _.bindAll(this);
        this.render();
        this.submitted = false;
        this.validate();
    },

    setType: function(e) {
        // Radio buttons - activate clicked button and disactivate all the others.
        // We can't use native radio buttons from bootstrap because of unpredictable event triggering order, btw.
        // See http://stackoverflow.com/questions/9262827/twitter-bootstrap-onclick-event-on-buttons-radio for details.
        $(e.target.parentElement).find('.active').removeClass('btn-primary');
        $(e.target.parentElement).find('.active').removeClass('active');
        $(e.target).button('toggle');
        $(e.target).addClass('btn-primary');
        this.validate();
    },

    disable: function() {
        this.$('.quest-add').addClass('disabled');
        this.enabled = false;
    },

    enable: function() {
        this.$('.quest-add').removeClass('disabled');
        this.enabled = true;
        this.submitted = false;
    },

    validate: function() {
        if (this.submitted || !this.getDescription()) {
            this.disable();
        }
        else {
            this.enable();
        }
    },

    getDescription: function() {
        return this.$('[name=name]').val();
    },

    render: function () {
        this.setElement($(this.template()));

        this.$('#addQuest').modal().css({
            'width': function () {
                return ($(document).width() * .8) + 'px';
            },
            'margin-left': function () {
                return -($(this).width() / 2);
            }
        });

        var qe = this.$('.quest-edit');
        this.$('#addQuest').modal().on('shown', function () {
            qe.focus();
        });
    },

    submit: function() {
        if (!this.enabled) {
            return;
        }

        var model_params = {
            name: this.getDescription()
        };

        var type = this.$('.quest-type-select button.active').attr('quest-type');
        if (type) {
            model_params.type = type;
        }

        var model = new this.collection.model();
        model.save(model_params, {
            'success': this.onSuccess,
            'error': pp.app.onError
        });

        this.submitted = true;
        this.validate();
    },

    onSuccess: function (model) {
        this.collection.add(model, { prepend: true });
        this.$('#addQuest').modal('hide');
    },
});
// Used by: views/quest/page.js
pp.views.QuestBig = pp.View.Common.extend({
    t: 'quest-big',

    // You know what, this view doesn't have to be deactivated; it could just setup the model listener itself.
    // But it's my initial attempt to implement 'activated: false' pattern, so I'll keep it as is for now.
    activated: false,

    events: {
        "click .quest-close": "close",
        "click .quest-abandon": "abandon",
        "click .quest-leave": "leave",
        "click .quest-join": "join",
        "click .quest-resurrect": "resurrect",
        "click .quest-reopen": "reopen",
        "click .delete": "destroy",
        "click .edit": "edit",
        "keypress .quest-edit": "updateOnEnter",
        "blur .quest-edit": "closeEdit"
    },

    subviews: {
        '.likes': function () {
            return new pp.views.Like({ model: this.model });
        }
    },

    afterInitialize: function () {
        this.listenTo(this.model, 'change', this.render);
    },

    close: function () {
        this.model.close();
    },

    abandon: function () {
        this.model.abandon();
    },

    leave: function () {
        this.model.leave();
    },

    join: function () {
        this.model.join();
    },

    resurrect: function () {
        this.model.resurrect();
    },

    reopen: function () {
        this.model.reopen();
    },

    edit: function () {
        if (!this.isOwned()) {
            return;
        }
        this.$('.quest-edit').show();
        this.$('.quest-title').hide();
        this.$('.quest-edit').focus();
    },

    updateOnEnter: function (e) {
        if (e.keyCode == 13) this.closeEdit();
    },

    closeEdit: function() {
        var value = this.$('.quest-edit').val();
        if (!value) {
            return;
        }
        this.model.save({ name: value });
        this.$('.quest-edit').hide();
        this.$('.quest-title').show();
    },

    destroy: function () {
        var that = this;
        bootbox.confirm("Quest and all comments will be destroyed permanently. Are you sure?", function(result) {
            if (result) {
                that.model.destroy({
                    success: function(model, response) {
                                 pp.app.router.navigate("/", { trigger: true });
                             },
                    error: pp.app.onError
                });
            }
        });
    },

    isOwned: function () {
        return (pp.app.user.get('login') == this.model.get('user'));
    },

    serialize: function () {
        var params = this.model.serialize();
        // TODO - should we move this to model?
        params.currentUser = pp.app.user.get('login');
        params.my = this.isOwned();
        if (!params.likes) {
            params.likes = [];
        }
        return params;
    },
});
pp.views.QuestCollection = pp.View.PagedCollection.extend({
    t: 'quest-collection',

    listSelector: '.quests-list',
    generateItem: function (quest) {
        return new pp.views.QuestSmall({
            model: quest,
            showAuthor: this.options.showAuthor
        });
    },

    // evil hack - ignore PagedCollection's afterRender, i.e. disable tooltip code
    afterRender: function () {
        pp.View.AnyCollection.prototype.afterRender.apply(this, arguments);
    }
});
pp.views.QuestPage = pp.View.Common.extend({
    t: 'quest-page',
    selfRender: true,

    subviews: {
        '.quest-big': function () {
            return new pp.views.QuestBig({
                model: this.model
            });
        },
        '.comments': function () {
            var commentsModel = new pp.models.CommentCollection([], { 'quest_id': this.model.id });
            commentsModel.fetch();
            return new pp.views.CommentCollection({
                collection: commentsModel
            });
        },
    },

    afterInitialize: function () {
        this.model.once('sync', function () {
            this.subview('.quest-big').activate();
        }, this);
        this.model.fetch();
    },

    afterRender: function () {
        // see http://stackoverflow.com/questions/6206471/re-render-tweet-button-via-js/6536108#6536108
        // $.ajax({ url: 'http://platform.twitter.com/widgets.js', dataType: 'script', cache:true});
    },
});
pp.views.QuestSmall = pp.View.Common.extend({
    t: 'quest-small',

    tagName: 'tr',
    className: 'quest-row',

    events: {
        'mouseenter': function (e) {
            this.subview('.likes').showButton();
        },
        'mouseleave': function (e) {
            this.subview('.likes').hideButton();
        }
    },

    subviews: {
        '.likes': function () {
            return new pp.views.Like({
                model: this.model,
                showButton: false
            });
        }
    },

    serialize: function () {
        var params = this.model.serialize();
        if (this.options.showAuthor) {
            params.showAuthor = true;
        }
        return params;
    },

    afterRender: function () {
        var className = 'quest-' + this.model.extStatus();
        this.$el.addClass(className);
    },

    features: ['tooltip']
});
pp.views.Like = pp.View.Common.extend({
    t: 'like',

    events: {
        "click .like": "like",
        "click .unlike": "unlike",
    },

    ownerField: 'user',

    afterInitialize: function () {
        if (this.options.showButton == undefined) {
            this._sb = true;
        }
        else {
            this._sb = this.options.showButton;
        }

        if (this.options.ownerField != undefined) {
            this.ownerField = this.options.ownerField;
        }
        this.listenTo(this.model, 'change', this.render);
    },

    showButton: function () {
        this.$('.like-button').show();
        this._sb = true;
    },

    hideButton: function () {
        this.$('.like-button').hide();
        this._sb = false;
    },

    like: function () {
        this.model.like();
    },

    unlike: function () {
        this.model.unlike();
    },

    serialize: function () {
        var likes = this.model.get('likes');
        var my = (pp.app.user.get('login') == this.model.get(this.ownerField));
        var currentUser = pp.app.user.get('login');
        var meGusta = _.contains(likes, currentUser);

        var params = {
            likes: this.model.get('likes'),
            my: (pp.app.user.get('login') == this.model.get(this.ownerField)),
            currentUser: pp.app.user.get('login'),
        };
        params.meGusta = _.contains(params.likes, params.currentUser);
        return params;
    },

    afterRender: function () {
        if (!this._sb) {
            this.hideButton();
        }
    },

    features: ['tooltip'],
});
// see also for the similar code: views/quest/add.js
// TODO - refactor them both into pp.View.Form
pp.views.Register = pp.View.Common.extend({
    t: 'register',

    events: {
       'click .submit': 'doRegister',
       'keydown [name=login]': 'checkEnter',
       'keyup [name=login]': 'validate'
    },

    subviews: {
        '.settings-subview': function () {
            var model = new pp.models.UserSettings({
                notify_likes: 1,
                notify_comments: 1
            });

            if (this.model.get('settings')) {
                model.set('email', this.model.get('settings')['email']);
                model.set('email_confirmed', this.model.get('settings')['email_confirmed']);
            }

            return new pp.views.UserSettings({ model: model });
        }
    },

    afterInitialize: function () {
        _.bindAll(this);
    },

    afterRender: function () {
        this.validate();
    },

    checkEnter: function (e) {
        if (e.keyCode == 13) {
          this.doRegister();
        }
    },

    getLogin: function () {
        return this.$('[name=login]').val();
    },

    disable: function() {
        this.$('.submit').addClass('disabled');
        this.$('.progress').toggle(this.submitted);
        this.enabled = false;
    },

    enable: function() {
        this.$('.submit').removeClass('disabled');
        this.$('.progress').hide();
        this.enabled = true;
        this.submitted = false;
    },

    validate: function() {
        var login = this.getLogin();
        if (login.match(/^\w*$/)) {
            this.$('.login').removeClass('error');
        }
        else {
            this.$('.login').addClass('error');
            login = undefined;
        }

        if (this.submitted || !login) {
            this.disable();
        }
        else {
            this.enable();
        }
    },

    doRegister: function () {
        if (!this.enabled) {
            return;
        }

        var that = this;

        // TODO - what should we do if login is empty?
        $.post('/api/register', {
            login: this.getLogin(),
            settings: JSON.stringify(this.subview('.settings-subview').deserialize())
        }).done(function (model, response) {
            pp.app.user.fetch({
                success: function () {
                    pp.app.router.navigate("/", { trigger: true });
                },
                error: function (model, response) {
                    pp.app.router.navigate("/welcome", { trigger: true });
                    pp.app.onError(model, response);
                }
            });
        })
        .fail(function (response) {
            // TODO - detect "login already taken" exceptions and render them appropriately
            pp.app.onError(false, response);

            // let's hope that server didn't register the user before it returned a error
            that.submitted = false;
            that.validate();
        })

        this.submitted = true;
        this.validate();
    }
});
pp.views.ConfirmEmail = pp.View.Common.extend({
    t: 'confirm-email',
    selfRender: true,
    afterInitialize: function () {
        $.post('/api/register/confirm_email', this.options)
        .done(function () {
            $('.alert').alert('close');
            pp.app.view.notify('success', 'Email confirmed.');
            pp.app.router.navigate('/', { trigger: true, replace: true });
        })
        .fail(function (response) {
            pp.app.onError(false, response);
            pp.app.router.navigate('/', { trigger: true, replace: true });
        });
    }
});
pp.views.CurrentUser = pp.View.Common.extend({

    t: 'current-user',

    events: {
        'click .logout': 'logout',
        'click .settings': 'settingsDialog',
        'click .login-with-persona': 'loginWithPersona',
        'click .notifications': 'notificationsDialog'
    },

    loginWithPersona: function () {
        navigator.id.request();
    },

    getSettingsBox: function () {
        if (!this._settingsBox) {
            this._settingsBox = new pp.views.UserSettingsBox({
                model: new pp.models.UserSettings()
            });
        }
        return this._settingsBox;
    },

    settingsDialog: function() {
        this.getSettingsBox().start();
    },

    notificationsDialog: function () {
        if (!this._notificationsBox) {
            this._notificationsBox = new pp.views.NotificationsBox({
                model: this.model
            });
        }
        this._notificationsBox.start();
    },

    needsToRegister: function () {
        if (this.model.get("registered")) {
            return;
        }

        if (
            this.model.get("twitter")
            || (
                this.model.get('settings')
                && this.model.get('settings').email
                && this.model.get('settings').email_confirmed
            )
        ) {
            return true;
        }
        return;
    },

    setPersonaWatch: function () {
        var persona = this.model.get('persona');
        var user = null;
        if (
            this.model.get('settings')
            && this.model.get('settings').email
            && this.model.get('settings').email_confirmed
            && this.model.get('settings').email_confirmed == 'persona'
        ) {
            user = this.model.get('settings').email;
        }

        var that = this;

        navigator.id.watch({
            loggedInUser: user,
            onlogin: function(assertion) {
                // A user has logged in! Here you need to:
                // 1. Send the assertion to your backend for verification and to create a session.
                // 2. Update your UI.
                $.ajax({
                    type: 'POST',
                    url: '/auth/persona',
                    data: { assertion: assertion },
                    success: function(res, status, xhr) {
                        that.model.fetch();
                    },
                    error: function(xhr, status, err) {
                        pp.app.view.notify(
                            'error',
                            '/auth/persona failed.'
                        );
                    }
                });
            },
            onlogout: that.backendLogout
        });
    },

    afterInitialize: function () {
        this.model = pp.app.user;
        this.model.once('sync', this.setPersonaWatch, this);

        this.listenTo(this.model, 'sync', this.checkUser);

        this.listenTo(this.model, 'change', this.render);
        this.listenTo(this.model, 'change', function () {
            var settingsModel = this.model.get('settings') || {};
            // now settings box will show the preview of (probably) correct settings even before it refetches its actual version
            // (see SettingsBox code for the details)
            this.getSettingsBox().model.clear().set(settingsModel);
        });
    },

    checkUser: function () {
        if (this.needsToRegister()) {
            pp.app.router.navigate("/register", { trigger: true, replace: true });
            return;
        }
        this.checkEmailConfirmed();
    },

    checkEmailConfirmed: function () {
        if (this.model.get('registered') && this.model.get('settings').email && !this.model.get('settings').email_confirmed) {
            pp.app.view.notify(
                'warning',
                'Your email address is not confirmed. Click the link we sent to ' + this.model.get('settings').email + ' to confirm it. (You can resend it from your settings if necessary.)'
            );
        }
    },

    backendLogout: function () {
        $.post('/api/logout').always(function () {
            window.location = '/';
        });
    },

    logout: function () {
        // TODO - fade to black until response
        if (this.model.get('settings') && this.model.get('settings').email_confirmed == 'persona') {
            navigator.id.logout();
        }
        else {
            this.backendLogout();
        }
    }
});
pp.views.Signin = pp.View.Common.extend({
    t: 'signin',

    events: {
        'click .login-with-persona': 'loginWithPersona'
    },

    loginWithPersona: function () {
        navigator.id.request();
    }
});
pp.views.UserSettings = pp.View.Common.extend({
    events: {
       'click .resend-email-confirmation': 'resendEmailConfirmation',
       'keyup [name=email]': 'typing'
    },

    t: 'user-settings',

    resendEmailConfirmation: function () {
        var btn = this.$('.resend-email-confirmation');
        if (btn.hasClass('disabled')) {
            return;
        }
        btn.addClass('disabled');

        $.post('/api/register/resend_email_confirmation', {})
        .done(function () {
            btn.text('Confirmation key sent');
        })
        .fail(function () {
            btn.text('Confirmation key resending failed');
        });
    },

    serialize: function () {
        var params = this.model.toJSON();
        params.hideEmailStatus = this.hideEmailStatus;
        return params;
    },

    start: function () {
        this.running = true;
        this.render();
        this.$('.email-status').show();
        this.$('[name=email]').removeAttr('disabled');
        this.$('[name=notify-comments]').removeAttr('disabled');
        this.$('[name=notify-likes]').removeAttr('disabled');
        this.hideEmailStatus = false;
    },

    stop: function () {
        this.running = false;
        this.$('.email-status').hide();
        this.$('[name=email]').attr({ disabled: 'disabled' });
        this.$('[name=notify-comments]').attr({ disabled: 'disabled' });
        this.$('[name=notify-likes]').attr({ disabled: 'disabled' });
    },

    typing: function() {
        // We need both.
        // First line hides status immediately...
        this.$('.email-status').hide();
        // Second line guarantees that it doesn't show up for a moment when we call save() and re-render.
        this.hideEmailStatus = true;
    },

    // i.e., parse the DOM and return the model params
    deserialize: function () {
        return {
            email: this.$('[name=email]').val(), // TODO - validate email
            notify_comments: this.$('[name=notify-comments]').is(':checked'),
            notify_likes: this.$('[name=notify-likes]').is(':checked')
        };
    },

    save: function(cbOptions) {
        this.model.save(this.deserialize(), cbOptions);
    },
});
// Here's the problem with modal views: you can't re-render them.
// Because when they have an internal state (background fade), and rendering twice means that you won't be able to close your modal, or it won't render at all.
// I'm not sure I understand it completely, but... I had problems with that.
//
// Because of that, UserSettingsBox and UserSettings are two different views.
//
// Also, separating modal view logic is a Good Thing in any case. This view can become 'pp.View.Modal' in the future.
pp.views.UserSettingsBox = pp.View.Common.extend({
    events: {
        'click .btn-primary': 'submit'
    },

    t: 'user-settings-box',

    subviews: {
        '.settings-subview': function () {
            return new pp.views.UserSettings({ model: this.model });
        }
    },

    afterInitialize: function() {
        this.setElement($('#user-settings')); // settings-box is a singleton
    },

    enable: function () {
        this.$('.icon-spinner').hide();
        this.subview('.settings-subview').start();
        this.$('.btn-primary').removeClass('disabled');
    },

    disable: function () {
        this.$('.icon-spinner').show();
        this.$('.btn-primary').addClass('disabled');
        this.subview('.settings-subview').stop();
    },

    start: function () {
        this.render();
        this.$('.modal').modal('show');

        this.disable();
        this.model.clear();

        var that = this;
        this.model.fetch({
            success: function () {
                that.enable();
            },
            error: function () {
                pp.app.view.notify('error', 'Unable to fetch settings');
                that.$('.modal').modal('hide');
            },
        });
    },

    submit: function() {

        this.disable();

        var that = this;
        this.subview('.settings-subview').save({
            success: function() {
                that.$('.modal').modal('hide');

                // Just to be safe.
                // Also, if email was changed, we want to trigger the 'sync' event and show the notify box.
                pp.app.user.fetch();
            },
            error: function() {
                pp.app.view.notify('error', 'Failed to save new settings');
                that.$('.modal').modal('hide');
            }
        });
    },
});
pp.views.Notifications = pp.View.Common.extend({
    t: 'notifications'
});
pp.views.NotificationsBox = pp.View.Common.extend({
    events: {
        'click .btn-primary': 'next'
    },

    t: 'notifications-box',

    subviews: {
        '.subview': function () {
            return new pp.views.Notifications({ model: this.model });
        }
    },

    afterInitialize: function() {
        this.setElement($('#notifications')); // settings-box is a singleton
    },

    start: function () {
        if (!this.current()) {
            return;
        }

        this.render();
        this.$('.modal').modal('show');
    },

    current: function () {
        return _.first(this.model.get('notifications'));
    },

    serialize: function () {
        return this.current();
    },

    next: function () {
        var that = this;

        this.model.dismissNotification(this.current()._id)
        .always(function () {
            that.model.fetch()
            .done(function () {
                if (!that.current()) {
                    that.$('.modal').modal('hide');
                    return;
                }
                that.subview('.subview').render();
            })
            .fail(function() {
                pp.app.view.notify('error', 'Failed to update notifications');
                that.$('.modal').modal('hide');
            });
        });
    },
});
// left column of the dashboard page
pp.views.UserBig = pp.View.Common.extend({
    t: 'user-big',

    events: {
        'click .settings': 'settingsDialog',
    },

    settingsDialog: function () {
        pp.app.view.currentUser.settingsDialog();
    },

    serialize: function () {
        var params = this.model.toJSON();

        var currentUser = pp.app.user.get('login');
        params.my = (currentUser && currentUser == this.model.get('login'));
        return params;
    },

    features: ['tooltip'],
});
pp.views.UserSmall = pp.View.Common.extend({
    t: 'user-small',

    tagName: 'tr',

    serialize: function () {
        var params = this.model.toJSON();
        params.currentUser = pp.app.user.get('login');
        return params;
    },

    afterRender: function () {
        var currentUser = pp.app.user.get('login');
        if (currentUser && this.model.get("login") == currentUser) {
            className = 'success';
        } else {
            className = 'warning';
        }
        this.$el.addClass(className);
    },
});
pp.views.UserCollection = pp.View.PagedCollection.extend({
    t: 'user-collection',
    listSelector: '.users-list',
    generateItem: function (model) {
        return new pp.views.UserSmall({
            model: model
        });
    },
});
pp.views.CommentCollection = pp.View.AnyCollection.extend({

    t: 'comment-collection',

    events: {
        'click .submit': 'postComment',
        'keyup [name=comment]': 'validate'
    },

    subviews: {
        '.signin': function () { return new pp.views.Signin(); }
    },

    celem: function () {
        return this.$('[name=comment]');
    },

    serialize: function () {
        return { currentUser: pp.app.user.get('login') };
    },

    generateItem: function (model) {
        return new pp.views.Comment({ model: model });
    },

    listSelector: '.comments-list',

    afterInitialize: function () {
        _.bindAll(this, 'onError');
        this.listenTo(this.collection, 'add', this.resetForm);
        pp.View.AnyCollection.prototype.afterInitialize.apply(this, arguments);
    },

    afterRender: function () {
        pp.View.AnyCollection.prototype.afterRender.apply(this, arguments);
        this.$('[name=comment]').autosize();
    },

    // set the appropriate "add comment" button style
    validate: function (e) {
        var text = this.celem().val();
        if (text) {
            this.$('.submit').removeClass('disabled');
            this.$('.comment-preview').show();
            this.$('.comment-preview').html(pp.app.view.markdownToHtml(text));
        }
        else {
            this.$('.submit').addClass('disabled');
            this.$('.comment-preview').hide();
        }
    },

    disableForm: function () {
        this.celem().attr({ disabled: 'disabled' });
        this.$('.submit').addClass('disabled');
    },

    resetForm: function () {
        this.celem().removeAttr('disabled');
        this.celem().val('');
        this.validate();
    },

    enableForm: function () {
        // the difference from resetForm() is that we don't clear textarea's val() to prevent the comment from vanishing
        this.celem().removeAttr('disabled');
        this.validate();
    },

    postComment: function() {
        if (this.$('.submit').hasClass('disabled')) {
            return;
        }
        this.disableForm();

        this.collection.create({
            'author': pp.app.user.get('login'),
            'body': this.celem().val()
        },
        {
            'wait': true,
            'error': this.onError
            // on success, 'add' will fire and form will be resetted
            // NB: if we'll implement streaming comments loading, this will need to be fixed
        });
    },

    onError: function(model, response) {
        pp.app.onError(model, response);
        this.enableForm();
    },
});
pp.views.Comment = pp.View.Common.extend({
    t: 'comment',

    events: {
        "click .delete": "destroy",
        "click .edit": "edit",
        "blur .comment-edit": "closeEdit",
        'mouseenter': function (e) {
            this.subview('.likes').showButton();
        },
        'mouseleave': function (e) {
            this.subview('.likes').hideButton();
        }
    },

    subviews: {
        '.likes': function () {
            return new pp.views.Like({ model: this.model, showButton: false, ownerField: 'author' });
        }
    },

    edit: function () {
        if (!this.isOwned()) {
            return;
        }
        this.$('.comment-edit').show();
        this.$('.comment-content').hide();
        this.$('.comment-edit').focus();
        this.$('.comment-edit').autosize();
    },

    closeEdit: function() {
        var edit = this.$('.comment-edit');
        if (edit.attr('disabled')) {
            return; // already saving
        }

        var value = edit.val();
        if (!value) {
            return; // empty comments are forbidden
        }

        var that = this;
        edit.attr('disabled', 'disabled');
        this.model.save({ body: value }, {
            success: function () {
                that.model.fetch({
                    success: function () {
                        edit.attr('disabled', false);
                        edit.hide();
                        this.$('.comment-content').show();
                        that.render();
                    },
                    error: function (model, xhr, options) {
                        pp.app.onError(model, xhr);
                        edit.attr('disabled', false);
                    },
                });
            },
            error: function (model, xhr) {
                pp.app.onError(model, xhr);
                edit.attr('disabled', false);
            }
        });
    },

    destroy: function () {
        var that = this;
        bootbox.confirm("Are you sure you want to delete this comment?", function(result) {
            if (result) {
                that.model.destroy({
                    wait: true,
                    error: pp.app.onError
                });
            }
        });
    },

    features: ['timeago'],

    serialize: function () {
        var params = this.model.toJSON();
        params.my = this.isOwned();

        return params;
    },

    isOwned: function () {
        return (pp.app.user.get('login') == this.model.get('author'));
    },
});
pp.views.EventBox = pp.View.Common.extend({
    t: 'event-any',
    subviews: {
        '.subview': function () {
            return new pp.views.Event({ model: this.model });
        },
    },

    features: ['timeago'],
});
pp.views.Event = pp.View.Base.extend({
    template: function () {
        var templateElem = $('#template-event-' + this.model.get('action') + '-' + this.model.get('object_type'));
        if (!templateElem.length) {
            templateElem = $('#template-event-unknown');
        }
        return _.template(templateElem.text());
    },

    render: function () {
        var template = this.template();
        var params = this.model.toJSON();
        params.partial = this.partial;
        this.$el.html(template(params));
        return this;
    }
});
pp.views.EventCollection = pp.View.PagedCollection.extend({
    tag: 'div',

    t: 'event-collection',

    listSelector: '.events-list',

    generateItem: function (model) {
        return new pp.views.EventBox({ model: model });
    }
});
pp.views.About = pp.View.Common.extend({
    t: 'about',
    selfRender: true,
});
// see models/user-collection.js for implementation example
pp.Collection.WithCgiAndPager = Backbone.Collection.extend({

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
pp.models.User = Backbone.Model.extend({

    initialize: function() {
        alert("trying to instantiate abstract base class");
    }
});
pp.models.AnotherUser = pp.models.User.extend({

    initialize: function () {
        this.on('error', pp.app.onError);
    },

    url: function () {
        return '/api/user/' + this.get('login');
    }
});
pp.models.CurrentUser = pp.models.User.extend({

    initialize: function () {
    },

    dismissNotification: function (_id) {
        return $.post(this.url() + '/dismiss_notification/' + _id);
    },

    url: function () {
        return '/api/current_user';
    },
});
pp.models.UserSettings = Backbone.Model.extend({
    url: '/api/current_user/settings',
});
pp.models.UserCollection = pp.Collection.WithCgiAndPager.extend({

    cgi: ['sort', 'order', 'limit', 'offset'],

    baseUrl: '/api/user',

    model: pp.models.AnotherUser
});
pp.models.Event = Backbone.Model.extend({
    idAttribute: '_id'
});
pp.models.EventCollection = pp.Collection.WithCgiAndPager.extend({
    baseUrl: '/api/event',
    cgi: ['limit', 'offset'],
    model: pp.models.Event
});
pp.models.Comment = Backbone.Model.extend({
    idAttribute: '_id',

    like: function() {
        this.act('like');
    },

    unlike: function() {
        this.act('unlike');
    },

    act: function(action) {
        var model = this;
        console.log(this.url());
        $.post(this.url() + '/' + action)
        .done(function () {
            model.fetch();
        });
    }
});
pp.models.CommentCollection = Backbone.Collection.extend({

    initialize: function(models, args) {
        this.url = function() {
            var url = '/api/quest/' + args.quest_id + '/comment';
            return url;
        };
        this.quest_id = args.quest_id;
    },
    model: pp.models.Comment

});
pp.models.Quest = Backbone.Model.extend({
    idAttribute: '_id',
    urlRoot: '/api/quest',

    like: function() {
        this.act('like');
    },

    unlike: function() {
        this.act('unlike');
    },

    join: function() {
        this.act('join');
    },

    leave: function() {
        this.act('leave');
    },

    close: function() {
        this._setStatus('closed');
    },

    abandon: function() {
        this._setStatus('abandoned');
    },

    resurrect: function() {
        this._setStatus('open');
    },

    reopen: function() {
        this._setStatus('open');
    },

    _setStatus: function(st) {
        var model = this.model;
        this.save(
            { "status": st },
            {
                success: function (model) {
                    if (model.get('user') == pp.app.user.get('login')) {
                        // update of the current user's quest causes update in points
                        pp.app.user.fetch();
                    }
                },
                error: pp.app.onError
            }
        );
    },

    act: function(action) {
        var model = this;
        $.post(this.url() + '/' + action)
            .success(function () {
                model.fetch();
            }); // TODO - error handling?
    },

    comment_count: function () {
        return this.get('comment_count') || 0;
    },

    like_count: function () {
        var likes = this.get('likes');
        if (likes) {
            return likes.length;
        }
        return 0;
    },

    extStatus: function () {
        var status = this.get('status');
        var user = this.get('user');

        if (status == 'open' && user == '') return 'unclaimed';
        return status;
    },

    // augments attributes with 'ext_status'
    serialize: function () {
        var params = this.toJSON();
        params.ext_status = this.extStatus();
        return params;
    }

});
pp.models.QuestCollection = pp.Collection.WithCgiAndPager.extend({
    defaultCgi: ['comment_count=1'],
    baseUrl: '/api/quest',
    cgi: ['user', 'status', 'limit', 'offset', 'sort', 'order', 'unclaimed'],
    model: pp.models.Quest
});
