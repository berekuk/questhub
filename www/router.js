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
    'views/news-feed',
    'views/quest/add',
    'views/about',
    'views/register',
    'views/confirm-email'
], function (Backbone, currentUser, Dashboard, QuestPage, QuestModel, UserCollectionModel, UserCollection, AnotherUserModel, Explore, Home, EventCollectionModel, NewsFeed, QuestAdd, About, Register, ConfirmEmail) {
    return Backbone.Router.extend({
        routes: {
            "": "dashboard",
            "welcome": "welcome",
            "register": "register",
            "register/confirm/:login/:secret": "confirmEmail",
            "auth/twitter": "twitterLogin",
            "quest/add": "questAdd",
            ":realm/quest/:id": "questPage",
            ":realm/feed": "feed",
            ":realm/players": "userList",
            ":realm/player/:login": "anotherDashboard",
            ":realm/explore(/:tab)": "explore",
            ":realm/explore/:tab/tag/:tag": "explore",
            "about": "about",

            "feed": "oldFeed",
            "players": "oldUserList",
            "explore(/:tab)": "oldExplore",
            "explore/:tab/tag/:tag": "oldExplore",
            "quest/:id": "oldQuestPage",
            "player/:login": "oldAnotherDashboard"
        },

        appView: undefined, // required

        // Google Analytics
        initialize: function(appView) {
            this.appView = appView;
            return this.bind('route', this._trackPageview);
        },
        _trackPageview: function() {
            var url = Backbone.history.getFragment();
            url = '/' + url;
            ga('send', 'pageview', {
                'page': url
            });
            mixpanel.track_pageview(url);
        },

        questAdd: function () {
            var view = new QuestAdd({ model: new QuestModel() });
            this.appView.setPageView(view);
            this.appView.setActiveMenuItem('add-quest');
        },

        questPage: function (realm, id) {
            var model = new QuestModel({ realm: realm, _id: id });
            var view = new QuestPage({ model: model });

            model.fetch({
                success: function () {
                    view.activate();
                }
            });

            this.appView.setPageView(view);
            this.appView.setActiveMenuItem('none');
        },

        welcome: function () {
            // model is usually empty, but sometimes it's not - logged-in users can see the welcome page too
            this.appView.setPageView(new Home({ model: currentUser }));

            this.appView.setActiveMenuItem('home');
        },

        dashboard: function () {
            throw "main page is temporarily disabled";
            this.navigate(
                '/' + this.appView.realm_id + '/player/' + currentUser.get('login'),
                { trigger: true, replace: true }
            );

            if (!currentUser.get('registered')) {
                this.navigate('/welcome', { trigger: true, replace: true });
                return;
            }

            var view = new Dashboard({ model: currentUser, current: true });
            view.activate(); // activate immediately, user is already fetched

            this.appView.setPageView(view);
            this.appView.setActiveMenuItem('home');
        },

        anotherDashboard: function (realm, login) {
            var user = new AnotherUserModel({ login: login });
            var view = new Dashboard({ realm: realm, model: user });
            user.fetch({
                success: function () {
                    view.activate();
                }
            });

            this.appView.setPageView(view);
            this.appView.setActiveMenuItem('none');
        },

        explore: function (realm, tab, tag) {
            var view = new Explore({ 'realm': realm });
            if (tab != undefined) {
                view.tab = tab;
            }
            if (tag != undefined) {
                view.tag = tag;
            }
            view.activate();

            this.appView.setPageView(view);
            this.appView.setActiveMenuItem('explore');
        },

        userList: function (realm) {
            var collection = new UserCollectionModel([], {
                'realm': realm,
                'sort': 'leaderboard',
                'limit': 100,
            });
            var view = new UserCollection({ collection: collection });
            collection.fetch();
            this.appView.setPageView(view);
            this.appView.setActiveMenuItem('user-list');
        },

        feed: function (realm) {
            var types = this.queryParams('types');
            if (types == '') {
                types = [];
            }
            else {
                types = types.split(',');
            }

            var collection = new EventCollectionModel([], {
                'realm': realm,
                'limit': 50,
                'types': types
            });
            var view = new NewsFeed({
                collection: collection,
                types: types
            });

            collection.fetch();
            view.render();

            this.appView.setPageView(view);
            this.appView.setActiveMenuItem('event-list');
        },

        register: function () {
            if (!this.appView.currentUser.needsToRegister()) {
                this.navigate("/", { trigger: true, replace: true });
                return;
            }

            var view = new Register({ model: currentUser });
            this.appView.setPageView(view); // not rendered yet
            this.appView.setActiveMenuItem('home');
            view.render();
        },

        confirmEmail: function (login, secret) {
            var view = new ConfirmEmail({ login: login, secret: secret });
            this.appView.setPageView(view);
            this.appView.setActiveMenuItem('none');
        },

        twitterLogin: function () {
            window.location = '/auth/twitter';
        },

        about: function () {
            this.appView.setPageView(new About());
            this.appView.setActiveMenuItem('about');
        },

        oldUserList: function () {
            this.navigate('/chaos/players', { trigger: true, replace: true });
        },

        oldFeed: function () {
            this.navigate('/chaos/feed', { trigger: true, replace: true });
        },

        oldExplore: function () {
            this.navigate('/chaos/explore', { trigger: true, replace: true });
        },

        oldQuestPage: function (id) {
            this.navigate('/chaos/quest/' + id, { trigger: true, replace: true });
        },

        oldAnotherDashboard: function (id) {
            console.log('todo - cross-realm profile');
        },

        queryParams: function(name) {
            name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
            var regexS = "[\\?&]" + name + "=([^&#]*)";
            var regex = new RegExp(regexS);
            var results = regex.exec(window.location.search);

            if(results == null){
                return "";
            } else {
                return decodeURIComponent(results[1].replace(/\+/g, " "));
            }
        }
    });
});
