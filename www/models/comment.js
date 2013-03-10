pp.models.Comment = Backbone.Model.extend({
    idAttribute: '_id',

    like: function() {
        this.act('like');
    },

    unlike: function() {
        this.act('unlike');
    },

    act: function(action) {
        var model = this;
        console.log(this.url());
        $.post(this.url() + '/' + action)
        .done(function () {
            model.fetch();
        });
    }
});
