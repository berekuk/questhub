define([
    'views/proto/common',
    'views/realm/controls',
    'text!templates/realm-detail.html'
], function (Common, RealmControls, html) {
    return Common.extend({
        template: _.template(html),

        subviews: {
            '.controls-subview': function () {
                return new RealmControls({ model: this.model });
            }
        },
    });
});
