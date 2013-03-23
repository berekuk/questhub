require.config({
    baseUrl: "/",
    paths: {
        // copy-pasted from /setup.js
        'backbone': 'vendors/backbone',
        'underscore': 'vendors/underscore',
        'jquery': 'vendors/jquery-1.7.1',
        'jquery.autosize': 'vendors/autosize/jquery.autosize',
        'jquery.timeago': 'vendors/jquery.timeago',
        'bootstrap': 'vendors/bootstrap/js/bootstrap',
        'bootbox': 'vendors/bootbox',
        // TODO - local storage

        'jasmine': 'test/lib/jasmine-1.3.1/jasmine',
        'jasmine-jquery': 'test/lib/jasmine-jquery',
        'jasmine-html': 'test/lib/jasmine-1.3.1/jasmine-html',
        'spec': 'test/spec/'
    },
    shim: {
        underscore: {
            exports: "_"
        },
        backbone: {
            deps: ['underscore', 'jquery'],
            exports: 'Backbone'
        },
//        'backbone.localStorage': {
//            deps: ['backbone'],
//            exports: 'Backbone'
//        },
        jasmine: {
            exports: 'jasmine'
        },
        'jasmine-html': {
            deps: ['jasmine'],
            exports: 'jasmine'
        },
        'jasmine-jquery': ['jasmine']
    }
});

require(['underscore', 'jquery', 'jasmine-html'], function(_, $, jasmine){

    var jasmineEnv = jasmine.getEnv();
    jasmineEnv.updateInterval = 1000;

    var htmlReporter = new jasmine.HtmlReporter();

    jasmineEnv.addReporter(htmlReporter);

    jasmineEnv.specFilter = function(spec) {
        return htmlReporter.specFilter(spec);
    };

    var specs = [];

    specs.push('spec/current-user');
    specs.push('spec/markdown');
    specs.push('spec/comment');
    specs.push('spec/quest-small');
    specs.push('spec/quest-big');

    $(function(){
        require(specs, function(){
            jasmineEnv.execute();
        });
    });

});
