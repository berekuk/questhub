(function () {

    require.config({
        baseUrl: "/",
        paths: {
            // copy-pasted from /setup.js
            'backbone': 'vendors/backbone',
            'underscore': 'vendors/underscore',
            'react': "vendors/react/react",
            'jquery': 'vendors/jquery-1.9.1',
            'jquery.autosize': 'vendors/jquery.autosize',
            'jquery.timeago': 'vendors/jquery.timeago',
            'bootstrap': 'vendors/bootstrap/js/bootstrap',
            'bootbox': 'vendors/bootbox',
            'jquery-ui': 'vendors/jquery-ui/js/jquery-ui-1.10.3.custom',
            // TODO - local storage

            'jasmine': 'test/lib/jasmine-1.3.1/jasmine',
            'jasmine-jquery': 'test/lib/jasmine-jquery',
            'jasmine-html': 'test/lib/jasmine-1.3.1/jasmine-html',
            'spec': 'test/spec/',
            'sinon': 'test/lib/sinon-1.7.3'
        },
        shim: {
            underscore: {
                exports: "_"
            },
            backbone: {
                deps: ['underscore', 'jquery'],
                exports: 'Backbone'
            },
            jasmine: {
                exports: 'jasmine'
            },
            sinon: {
                exports: 'sinon'
            },
            'jasmine-html': {
                deps: ['jasmine'],
                exports: 'jasmine'
            },
            'jasmine-jquery': ['jasmine']
        }
    });

    require([
        'underscore', 'backbone', 'jquery', 'jasmine-html', 'models/current-user', 'models/shared-models', 'sinon'
    ], function(_, Backbone, $, jasmine, currentUser, sharedModels) {

        var jasmineEnv = jasmine.getEnv();
        jasmineEnv.updateInterval = 1000;

        var htmlReporter = new jasmine.HtmlReporter();

        jasmineEnv.addReporter(htmlReporter);

        jasmineEnv.specFilter = function(spec) {
            return htmlReporter.specFilter(spec);
        };

        var specs = [];

        specs.push(
            'spec/markdown',
            'spec/textarea',
            'spec/navbar', 'spec/current-user', 'spec/settings',
            'spec/register',
            'spec/quest-small', 'spec/quest-big', 'spec/quest-add',
            'spec/comment', 'spec/like',
            'spec/event',
            'spec/realm', 'spec/realm-controls',
            'spec/dashboard', 'spec/user-big',
            'spec/model/quest', 'spec/model/event', 'spec/model/current-user', 'spec/model/realm', 'spec/model/user'
        );

        // evil mocks
        // mocking Mixpanel
        mixpanel = {
            init: function () {},
            track: function () {},
            identify: function () {},
            people: { set: function () {} },
            alias: function () {},
            name_tag: function () {},
        };
        // mocking Google Analytics
        ga = function () {};

        // mocking Persona
        navigator.id = {
            watch: function () {},
            request: function () {},
            logout: function () {},
        };

        Backbone.history.start();

        currentUser.set({
            registered: 1,
            login: 'jasmine',
            _id: '12345678901234567890abcd',
            settings: {},
            notifications: [],
            pic: "/current-user.png"
        });

        sharedModels.realms.set([
            { id: 'europe', name: 'Europe', description: 'europe-europe', pic: 'europe.jpg', stat: { users: 0, quests: 0, stencils: 0 } },
            { id: 'asia', name: 'Asia', description: 'asia-asia', pic: 'asia.jpg', stat: { users: 0, quests: 0, stencils: 0 }  }
        ]);

        $(function() {
            require(specs, function() {
                jasmineEnv.execute();
            });
        });

    });
})();
