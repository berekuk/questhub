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
            'success': function() {},
            'error': this.onError
        });
    },

    onError: function(model, response) {
                $('#layout > .container').prepend(
                    new pp.views.Error({
                        response: response
                    }).render().el
                );
                //console.log(.error)
            }
});
