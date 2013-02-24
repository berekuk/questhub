pp.views.Signin = pp.View.Common.extend({
    t: 'signin',

    events: {
        'click .login-with-persona': 'loginWithPersona'
    },

    loginWithPersona: function () {
        navigator.id.request();
    }
});
