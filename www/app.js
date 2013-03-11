$(function () {
    pp.app.user = new pp.models.CurrentUser();

    var appView = pp.app.view = new pp.views.App({el: $('#wrap')});

    pp.app.onError = function(model, response) {
        var error;
        try {
            var parsedResponse = jQuery.parseJSON(response.responseText);
            error = parsedResponse.error;
        }
        catch(e) {
            error = "HTTP ERROR: " + response.status + " " + response.statusText;
        }

        console.log('error: ' + error);
        pp.app.view.notify('error', error);
    };

    pp.app.router = new pp.Router(appView);

    pp.app.user.fetch({
        success: function () {
            // We're waiting for CurrentUser to be loaded before everything else.
            // It's a bit slower than starting the router immediately, but it prevents a few nasty race conditions.
            // Also, it's done just once, so all following navigation is actually *faster*.
            Backbone.history.start({ pushState: true });
            pp.app.user.on("error", pp.app.onError);
        },
        error: pp.app.onError, // todo - try to refetch user in a loop until backends goes online
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
            pp.app.router.navigate(url, { trigger: true });
        }
    });
});
