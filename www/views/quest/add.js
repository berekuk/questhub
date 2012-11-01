pp.views.QuestAdd = Backbone.View.extend({
    events: {
        'click .submit': 'saveToModel'
    },

    template: _.template($('#template-quest-add').text()),

    initialize: function () {
        this.setElement($(this.template()));
    },

    saveToModel: function() {
        this.model.save({
            'name': this.$('[name=name]').val()
        },
        {
            'success': this.onSuccess,
            'error': this.onError
        });
    },

    onError: pp.app.onError,

    onSuccess: function (model) {
        pp.app.router.navigate('quests', { trigger: true });
        $('#layout > .container').prepend(
                    new pp.views.Notify({
                        // Whoops! It is injection here, model.name should be sanitized
                        text: 'Quest "'+model.get('name')+'" has been add succesfully added'
                    }).render().el
        );
    }
});
