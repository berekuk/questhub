define([
    'backbone',
    'models/current-user',
    'views/dashboard',
    'views/quest/page', 'models/quest',
    'models/user-collection', 'views/user/collection', 'models/another-user',
    'views/explore', 'views/welcome',
    'models/event-collection', 'views/news-feed',
    'views/realm/page',
    'views/about', 'views/register',
    'views/realm/detail-collection', 'models/realm-collection', 'models/realm',
    'views/confirm-email', 'views/user/unsubscribe'
], function (
    Backbone,
    currentUser,
    Dashboard,
    QuestPage, QuestModel,
    UserCollectionModel, UserCollection, AnotherUserModel,
    Explore, Welcome,
    EventCollectionModel, NewsFeed,
    RealmPage,
    About, Register,
    RealmDetailCollection, RealmCollectionModel, RealmModel,
    ConfirmEmail, Unsubscribe
) {

    var router;

    var redirect = function (tmpl) {
        return function () {
            var newRoute = tmpl;
            newRoute = newRoute.replace(':1', arguments[0]);
            newRoute = newRoute.replace(':2', arguments[1]);
            newRoute = newRoute.replace(':3', arguments[2]);
            router.navigate('/' + newRoute, { trigger: true, replace: true });
        }
    };

    return Backbone.Router.extend({
        routes: {
            "": "feed",
            "welcome": "welcome",

            "register": "register",
            "register/confirm/:login/:secret": "confirmEmail",
            "auth/twitter": "twitterLogin",
            "player/:login/unsubscribe/:field/:status": "unsubscribeResult",

            "feed": "feed",

            "quest/:id": "questPage",
            "realm/:realm": "realmPage",
            "player/:login": "dashboard",
            "about": "about",
            "realms": "realms",
            "realm/:realm/players": "userList",
            "realm/:realm/explore(/:tab)": "explore",
            "realm/:realm/explore/:tab/tag/:tag": "explore",
            "realm/:realm/quest/:id": "realmQuestPage",

            // legacy
            "perl": redirect('realm/perl'),
            "perl/": redirect('realm/perl'),
            "players": redirect(''),
            "explore": redirect('realm/chaos/explore'),
            "explore/:tab": redirect('realm/chaos/explore/:1'),
            "explore/:tab/tag/:tag": redirect('realm/chaos/explore/:1/tag/:2'),
            ":realm/player/:login": redirect('realm/:1/player/:2'),
            ":realm/explore": redirect('realm/:1/explore'),
            ":realm/explore/:tab": redirect('realm/:1/explore/:2'),
            ":realm/explore/:tab/tag/:tag": redirect('realm/:1/explore/:2/tag/:3'),
            ":realm/players": redirect('realm/:1/players'),
            ":realm/feed": redirect('realm/:1'),
            ":realm/quest/:id": redirect('quest/:2')
        },

        appView: undefined, // required

        // Google Analytics
        initialize: function(appView) {
            this.appView = appView;
            this.bind('route', this._trackPageview);
            router = this;
        },
        _trackPageview: function() {
            var url = Backbone.history.getFragment();
            url = '/' + url;
            ga('send', 'pageview', {
                'page': url
            });
            mixpanel.track_pageview(url);
        },

        questPage: function (id) {
            var model = new QuestModel({ _id: id });
            var view = new QuestPage({ model: model });

            var router = this;

            model.fetch({
                success: function () {
                    router.navigate('/realm/' + model.get('realm') + '/quest/' + model.id, { trigger: true, replace: true });
                    view.activate();
                }
            });

            this.appView.setPageView(view);
        },

        realmQuestPage: function (realm, id) {
            this.questPage(id);
        },

        welcome: function () {
            // model is usually empty, but sometimes it's not - logged-in users can see the welcome page too
            this.appView.setPageView(new Welcome({ model: currentUser }));
        },

        frontPage: function () {
            if (!currentUser.get('registered')) {
                this.navigate('/welcome', { trigger: true, replace: true });
                return;
            }

            var realms = currentUser.get('realms');
            if (this.appView.realm_id) {
                this.navigate(
                    '/' + this.appView.realm_id + '/player/' + currentUser.get('login'),
                    { trigger: true, replace: true }
                );
            }
            else if (realms.length) {
                this.navigate(
                    '/' + realms[0] + '/player/' + currentUser.get('login'),
                    { trigger: true, replace: true }
                );
            }
            else {
                this.navigate('/welcome', { trigger: true, replace: true });
            }
        },

        dashboard: function (login) {
            var currentLogin = currentUser.get('login');

            var model;
            var my;
            if (currentLogin && currentLogin == login) {
                model = currentUser;
                my = true;
            }
            else {
                model = new AnotherUserModel({ login: login });
            }

            var view = new Dashboard({ model: model });

            if (my) {
                view.activate(); // activate immediately, user is already fetched
            }
            else {
                model.fetch({
                    success: function () {
                        view.activate();
                    }
                });
            }

            this.appView.setPageView(view);
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
        },

        realmPage: function (realm) {
            var model = new RealmModel({ id: realm });
            var view = new RealmPage({ model: model });
            model.fetch().success(function () {
                view.activate();
            });
            this.appView.setPageView(view);
        },

        feed: function () {
            if (!currentUser.get('registered')) {
                this.navigate('/welcome', { trigger: true, replace: true });
                return;
            }

            var types = this.queryParams('types');
            if (types == '') {
                types = [];
            }
            else {
                types = types.split(',');
            }

            var view = new NewsFeed({
                model: currentUser,
                types: types
            });
            view.render();

            this.appView.setPageView(view);
        },

        register: function () {
            if (!currentUser.needsToRegister()) {
                this.navigate("/", { trigger: true, replace: true });
                return;
            }

            mixpanel.track('register form');

            var view = new Register({ model: currentUser });
            this.appView.setPageView(view); // not rendered yet
            view.render();
        },

        confirmEmail: function (login, secret) {
            var view = new ConfirmEmail({ login: login, secret: secret });
            this.appView.setPageView(view);
        },

        unsubscribeResult: function (login, field, status) {

            if (status != 'ok') {
                mixpanel.track('unsubscribe fail');
            }
            else {
                mixpanel.track('unsubscribe', {
                    login: login,
                    field: field,
                    via: 'email'
                });
            }

            this.navigate("/", { replace: true }); // so that nobody links to unsubscribe page - this would be confusing
            var view = new Unsubscribe({ login: login, field: field, status: status });
            this.appView.setPageView(view);
        },

        twitterLogin: function () {
            window.location = '/auth/twitter';
        },

        about: function () {
            this.appView.setPageView(new About());
        },

        realms: function () {
            var view = new RealmDetailCollection({
                collection: new RealmCollectionModel()
            });
            view.collection.fetch();
            this.appView.setPageView(view);
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
