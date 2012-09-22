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

    onError: function(model, response) {
                $('#layout > .container').prepend(
                    new pp.views.Error({
                        response: response
                    }).render().el
                );
            },
    
    onSuccess: function (model) {
        pp.app.router.navigate('quests', { trigger: true });
        $('#layout > .container').prepend(
                    new pp.views.Notify({
                        // Whoops! It is injection here, model.name should be sanitized
                        text: 'Quest "'+model.name+'"" has been add succesfully added'
                    }).render().el
        );
    }
});
