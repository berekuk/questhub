pp.View.Base = Backbone.View.extend({

    partial: {
        user: _.template($('#partial-user').text())
    }
});
