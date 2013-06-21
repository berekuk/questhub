define([
    'underscore',
    'views/proto/common',
    'models/current-user',
    'text!templates/user-small.html'
], function (_, Common, currentUser, html) {
    return Common.extend({
        template: _.template(html),

        tagName: 'tr',

        serialize: function () {
            var params = this.model.toJSON();
            params.currentUser = currentUser.get('login');
            params.realm = this.options.realm;
            return params;
        },
    });
});
