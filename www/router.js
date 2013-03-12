define([
    'backbone',
    'models/current-user',
    'views/dashboard',
    'views/quest/page',
    'models/quest',
    'models/user-collection',
    'views/user/collection',
    'models/another-user',
    'views/explore',
    'views/home',
    'models/event-collection',
    'views/event/collection'
], function (Backbone, currentUser, Dashboard, QuestPage, QuestModel, UserCollectionModel, UserCollection, AnotherUserModel, Explore, Home, EventCollectionModel, EventCollection) {
    return Backbone.Router.extend({
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
            var view = new QuestPage({ model: new QuestModel({ _id: id }) });
            this.appView.setPageView(view);
            this.appView.setActiveMenuItem('none');
        },

        welcome: function () {
            // model is usually empty, but sometimes it's not - logged-in users can see the welcome page too
            this.appView.setPageView(new Home({ model: currentUser }));

            this.appView.setActiveMenuItem('home');
        },

        dashboard: function () {
            if (!currentUser.get('registered')) {
                this.navigate('/welcome', { trigger: true, replace: true });
                return;
            }

            var view = new Dashboard({ model: currentUser, current: true });
            view.activate(); // activate immediately, user is already fetched

            this.appView.setPageView(view);
            this.appView.setActiveMenuItem('home');
        },

        anotherDashboard: function (login) {
            var user = new AnotherUserModel({ login: login });
            var view = new Dashboard({ model: user });
            user.fetch({
                success: function () {
                    view.activate();
                }
            });

            this.appView.setPageView(view);
            this.appView.setActiveMenuItem('none');
        },

        explore: function (tab) {
            var view = new Explore();
            if (tab != undefined) {
                view.tab = tab;
            }
            view.activate();

            this.appView.setPageView(view);
            this.appView.setActiveMenuItem('explore');
        },

        userList: function () {
            var collection = new UserCollectionModel([], {
               'sort': 'leaderboard',
                'limit': 100,
            });
            var view = new UserCollection({ collection: collection });
            collection.fetch();
            this.appView.setPageView(view);
            this.appView.setActiveMenuItem('user-list');
        },

        eventCollection: function () {
            var collection = new EventCollectionModel([], {
                'limit': 100
            });
            var view = new EventCollection({ collection: collection });
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
});
