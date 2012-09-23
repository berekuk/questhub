PlayPerl.Router = Ember.Router.extend({
  root: Ember.Route.extend({
    index: Ember.Route.extend({
      route: '/',
      redirectsTo: 'home'
    }),
    home: Ember.Route.extend({
      route: '/home'
    }),
    quests: Ember.Route.extend({
      route: '/quests'.

      index: Ember.Route.extend({
        route: '/'
      }),
      create: Ember.Route.extend({
        route: '/create'
      }),
      read: Ember.Route.extend({
        route: '/:id'
      }),
    }),
  })
});
