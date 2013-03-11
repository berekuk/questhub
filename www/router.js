pp.Router = Backbone.Router.extend({
    routes: {
        "": "dashboard",
        "welcome": "welcome",
        "register": "register",
        "register/confirm/:login/:secret": "confirmEmail",
        "auth/twitter": "twitterLogin",
        "quest/add": "questAdd",
        "quest/:id": "questPage",
        "feed": "eventCollection",
        "players": "userList",
        "player/:login": "anotherDashboard",
        "explore(/:tab)": "explore",
        "about": "about",
    },

    appView: undefined, // required

    // Google Analytics
    initialize: function(appView) {
        this.appView = appView;
        return this.bind('all', this._trackPageview);
    },
    _trackPageview: function() {
        var url;
        url = Backbone.history.getFragment();
        return _gaq.push(['_trackPageview', "/" + url]);
    },

    questAdd: function () {
        var view = new pp.views.QuestAdd({ model: new pp.models.Quest() });
        this.appView.setPageView(view);
        this.appView.setActiveMenuItem('add-quest');
    },

    questPage: function (id) {
        var view = new pp.views.QuestPage({ model: new pp.models.Quest({ _id: id }) });
        this.appView.setPageView(view);
        this.appView.setActiveMenuItem('none');
    },

    welcome: function () {
        // model is usually empty, but sometimes it's not - logged-in users can see the welcome page too
        this.appView.setPageView(new pp.views.Home({ model: pp.app.user }));

        this.appView.setActiveMenuItem('home');
    },

    dashboard: function () {
        if (!pp.app.user.get('registered')) {
            this.navigate('/welcome', { trigger: true, replace: true });
            return;
        }

        var view = new pp.views.Dashboard({ model: pp.app.user, current: true });
        view.activate(); // activate immediately, user is already fetched

        this.appView.setPageView(view);
        this.appView.setActiveMenuItem('home');
    },

    anotherDashboard: function (login) {
        var user = new pp.models.AnotherUser({ login: login });
        var view = new pp.views.Dashboard({ model: user });
        user.fetch({
            success: function () {
                view.activate();
            },
            error: pp.app.onError,
        });

        this.appView.setPageView(view);
        this.appView.setActiveMenuItem('none');
    },

    explore: function (tab) {
        var view = new pp.views.Explore();
        if (tab != undefined) {
            view.tab = tab;
        }
        view.activate();

        this.appView.setPageView(view);
        this.appView.setActiveMenuItem('explore');
    },

    userList: function () {
        var collection = new pp.models.UserCollection([], {
           'sort': 'leaderboard',
            'limit': 100,
        });
        var view = new pp.views.UserCollection({ collection: collection });
        collection.fetch({ error: pp.app.onError });
        this.appView.setPageView(view);
        this.appView.setActiveMenuItem('user-list');
    },

    eventCollection: function () {
        var collection = new pp.models.EventCollection([], {
            'limit': 100
        });
        var view = new pp.views.EventCollection({ collection: collection });
        collection.fetch();
        this.appView.setPageView(view);
        this.appView.setActiveMenuItem('event-list');
    },

    register: function () {
        console.log('route /register');
        if (!pp.app.view.currentUser.needsToRegister()) {
            console.log('going to /');
            this.navigate("/", { trigger: true, replace: true });
            return;
        }

        var view = new pp.views.Register({ model: pp.app.user });
        this.appView.setPageView(view); // not rendered yet
        this.appView.setActiveMenuItem('home');
        view.render();
        console.log('rendered /register');
    },

    confirmEmail: function (login, secret) {
        var view = new pp.views.ConfirmEmail({ login: login, secret: secret });
        this.appView.setPageView(view);
        this.appView.setActiveMenuItem('none');
    },

    twitterLogin: function () {
        window.location = '/auth/twitter';
    },

    about: function () {
        this.appView.setPageView(new pp.views.About());
        this.appView.setActiveMenuItem('about');
    }
});
