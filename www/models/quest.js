pp.models.Quest = Backbone.Model.extend({
    urlRoot: '/api/quest',
    close: function() {
        this.save(
            { "status": "closed" },
            {
                "error": function(model, response) {
                    // this function will soon be copy-pasted everywhere
                    // FIXME - move it to pp.addError() global method?
                    $('#layout > .container').prepend(
                        new pp.views.Error({
                            response: response
                        }).render().el
                    );
                }
            }
        );
    },
});
