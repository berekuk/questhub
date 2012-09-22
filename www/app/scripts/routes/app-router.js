Www.Router = Ember.Router.extend({
  root: Ember.State.extend({
    index: Ember.State.extend({
      route: '/',
      redirectsTo: 'home'
    }),
    home: Ember.State.extend({
      route: '/home'
    }),
    quest: Ember.State.extend({
      route: '/quests'
      
      plan: Ember.State.extend({
        route: '/plan'
      })
    })
  })
});
