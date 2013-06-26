define([
    'underscore', 'jquery',
    'views/proto/common',
    'text!templates/confirm-email.html'
], function (_, $, Common, html) {
    return Common.extend({
        template: _.template(html),

        selfRender: true,

        afterInitialize: function () {
            $.post('/api/register/confirm_email', this.options)
            .done(function () {
                $('.alert').alert('close');

                ga('send', 'event', 'confirm-email', 'ok');
                mixpanel.track('confirm-email ok');

                Backbone.trigger('pp:notify', 'success', 'Email confirmed.');
                Backbone.trigger('pp:navigate', '/', { trigger: true, replace: true });
            })
            .fail(function (response) {
                ga('send', 'event', 'confirm-email', 'failed');
                mixpanel.track('confirm-email failed');

                Backbone.trigger('pp:navigate', '/', { trigger: true, replace: true });
            });
        }
    });
});
