require([
    'jquery',
    'router',
    'views/app', 'models/current-user',
    'bootstrap', 'jquery.autosize', 'jquery.timeago' // move these into appropriate modules
],
function($, Router, App, currentUser) {

    var appView = new App({ el: $('#wrap') });

    $(document).ajaxError(function () {
        appView.notify('error', 'Internal HTTP error');
        ga('send', 'event', 'server', 'error');
        //var error;
        //try {
        //    error = $.parseJSON(response.responseText).error;
        //}
        //catch(e) {
        //    error = "HTTP ERROR: " + response.status + " " + response.statusText;
        //}

        //console.log('error: ' + error);
        //appView.notify('error', error);
    });

    var router = new Router(appView);
    Backbone.on('pp:navigate', function (url, options) {
        router.navigate(url, options);
    });
    Backbone.on('pp:notify', function (type, message) {
        appView.notify(type, message);
    });
    Backbone.on('pp:settings-dialog', function () {
        appView.currentUser.settingsDialog();
        ga('send', 'event', 'settings', 'open');
    });

    currentUser.fetch({
        success: function () {
            // We're waiting for CurrentUser to be loaded before everything else.
            // It's a bit slower than starting the router immediately, but it prevents a few nasty race conditions.
            // Also, it's done just once, so all following navigation is actually *faster*.
            Backbone.history.start({ pushState: true });
        },
        // TODO - try to refetch user in a loop until backends goes online
    });

    $(document).on("click", "a[href='#']", function(event) {
        if (!event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey) {
            event.preventDefault();
        }
    });

    $(document).on("click", "a[href^='/']", function(event) {
        if (!event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey) {
            event.preventDefault();
            var url = $(event.currentTarget).attr("href").replace(/^\//, "");
            router.navigate(url, { trigger: true });
        }
    });
});
