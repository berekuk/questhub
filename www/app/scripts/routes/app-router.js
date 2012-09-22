Www.Router = Ember.Router.extend({
  root: Ember.Route.extend({
    index: Ember.Route.extend({
      route: '/',
      redirectsTo: 'home'
    }),
    home: Ember.Route.extend({
      route: '/home'
    }),
    quest: Ember.Route.extend({
      route: '/quests',
      
      plan: Ember.Route.extend({
        route: '/plan'
      })
    })
  })
});
