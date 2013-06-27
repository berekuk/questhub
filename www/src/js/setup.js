requirejs.config({
    paths: {
        'backbone': 'vendor/backbone',
        'underscore': 'vendor/underscore',
        'jquery': 'vendor/jquery-1.9.1',
        'jquery.autosize': 'vendor/autosize/jquery.autosize',
        'jquery.timeago': 'vendor/jquery.timeago',
        'bootstrap': 'vendor/bootstrap/js/bootstrap',
        'bootbox': 'vendor/bootbox',
        'jquery-ui': 'vendor/jquery-ui/js/jquery-ui-1.10.3.custom'
    },
    deps: ['app'],
    shim: {
        backbone: {
            deps: ["underscore", "jquery"],
            exports: "Backbone"
        },
        underscore: {
            exports: "_"
        },

        'jquery.autosize': ['jquery'],
        'jquery.timeago': ['jquery'],
        'jquery-ui': {
            exports: '$',
            deps: ['jquery']
        },

        'bootstrap': ['jquery'],
        bootbox: {
            exports: "bootbox"
        }
    }
});
