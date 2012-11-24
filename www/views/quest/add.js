pp.views.QuestAdd = Backbone.View.extend({
    events: {
        'click .quest-add': 'saveToModel'
    },

    template: _.template($('#template-quest-add').text()),

    initialize: function() {
        _.bindAll(this);
        this.render();
    },

    render: function () {
        this.setElement($(this.template()));

        this.$el.find('#addQuest').modal().css({
            'width': function () {
                return ($(document).width() * .8) + 'px';
            },
            'margin-left': function () {
                return -($(this).width() / 2);
            }
        });
    },

    saveToModel: function() {
        console.log(this.collection);
        var model = new this.collection.model();
        model.save({
            name: this.$('[name=name]').val()
        }, {
            'success': this.onSuccess,
            'error': pp.app.onError
        });
    },

    onSuccess: function (model) {
        console.log(model);
        this.collection.add(model);
        this.$el.find('#addQuest').modal('hide');
    }
});
