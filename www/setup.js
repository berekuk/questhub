requirejs.config({
    paths: {
        'backbone': 'vendors/backbone-min',
        'underscore': 'vendors/underscore-min',
        'jquery': 'vendors/jquery-1.7.1.min',
        'jquery.autosize': 'vendors/autosize/jquery.autosize',
        'jquery.timeago': 'vendors/jquery.timeago',
        'bootstrap': 'vendors/bootstrap/js/bootstrap.min',
        'bootbox': 'vendors/bootbox.min',
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
