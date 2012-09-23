Handlebars.registerHelper('urlFor', function(state) {
  var url = PlayPerl.router.urlFor(state);
  return url;
});

var PlayPerl = Ember.Application.create();
