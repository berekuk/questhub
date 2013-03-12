define([
    'jquery',
    'views/proto/common'
], function ($, Common) {
    return Common.extend({
        t: 'confirm-email',
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
