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
                Backbone.trigger('pp:notify', 'success', 'Email confirmed.');
                Backbone.trigger('pp:navigate', '/', { trigger: true, replace: true });
            })
            .fail(function (response) {
                Backbone.trigger('pp:navigate', '/', { trigger: true, replace: true });
            });
        }
    });
});
