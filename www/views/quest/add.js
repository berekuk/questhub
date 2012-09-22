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
    		'text': this.$('[name=text]').val()
    	});
    }
});