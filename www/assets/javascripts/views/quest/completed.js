define([
    'underscore',
    'views/proto/common',
    'models/current-user',
    'text!templates/quest-completed.html',
], function (_, Common, currentUser, html) {
    return Common.extend({
        template: _.template(html),

        events: {
            'click .btn-primary': 'stop'
        },

        afterInitialize: function() {
            this.setElement($('#quest-completed-modal'));
        },

        start: function () {
            this.render();
            this.$('.modal').modal('show');

            $.getScript("http://platform.twitter.com/widgets.js");
            //!function (d,s,id) {
            //    var js,fjs=d.getElementsByTagName(s)[0];
            //    if(!d.getElementById(id)){
            //        js=d.createElement(s);
            //        js.id=id;
            //        js.src="//platform.twitter.com/widgets.js";
            //        fjs.parentNode.insertBefore(js,fjs);
            //    }
            //} (document,"script","twitter-wjs");
        },

        stop: function () {
            this.$('.modal').modal('hide');
        },

        serialize: function () {
            var params = this.model.serialize();
            params.gotTwitter = Boolean(currentUser.get('twitter'));
            params.totalPoints = params.reward + currentUser.get('rp')[this.model.get('realm')];
            return params;
        }
    });
});
