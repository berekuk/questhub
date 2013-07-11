requirejs.config
    paths:
        backbone: "vendors/backbone"
        underscore: "vendors/underscore"
        jquery: "vendors/jquery-1.9.1"
        "jquery.autosize": "vendors/autosize/jquery.autosize"
        "jquery.timeago": "vendors/jquery.timeago"
        "jquery.typeahead": "vendors/typeahead"
        bootstrap: "vendors/bootstrap/js/bootstrap"
        bootbox: "vendors/bootbox"
        "jquery-ui": "vendors/jquery-ui/js/jquery-ui-1.10.3.custom"

    deps: ["app"]
    shim:
        backbone:
            deps: ["underscore", "jquery"]
            exports: "Backbone"

        underscore:
            exports: "_"

        "jquery.autosize": ["jquery"]
        "jquery.timeago": ["jquery"]
        "jquery.typeahead": ["jquery"]
        "jquery-ui":
            exports: "$"
            deps: ["jquery"]

        bootstrap: ["jquery"]
        bootbox:
            exports: "bootbox"

