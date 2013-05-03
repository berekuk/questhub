define([
    'settings',
    'views/proto/common',
    'text!templates/realm-small.html'
], function (settings, Common, html) {
    return Common.extend({
        template: _.template(html),

        serialize: function () {
            var view = this;
            var realm = _.find(
                settings.realms,
                function (r) {
                    return r.id == view.options.realm;
                }
            );
            return realm;
        },
    });
});
