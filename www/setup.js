requirejs.config({
    paths: {
        'backbone': 'vendors/backbone',
        'underscore': 'vendors/underscore',
        'jquery': 'vendors/jquery-1.9.1',
        'jquery.autosize': 'vendors/autosize/jquery.autosize',
        'jquery.timeago': 'vendors/jquery.timeago',
        'bootstrap': 'vendors/bootstrap/js/bootstrap',
        'bootbox': 'vendors/bootbox'
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
        bootbox: {
            exports: "bootbox"
        },
        'jquery.autosize': ['jquery'],
        'jquery.timeago': ['jquery'],
        'bootstrap': ['jquery']
    }
});
