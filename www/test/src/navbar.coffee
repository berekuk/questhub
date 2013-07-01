define ["views/navbar"], (Navbar) ->
  describe "navbar", ->
    describe "when rendered", ->
      view = new Navbar(realm: "asia")
      view.render()
      it "is a nav", ->
        expect(view.$el).toContain "nav"


    describe "active", ->
      view = new Navbar(realm: "asia")
      it "is empty by default", ->
        view.render()
        expect(view.$el).not.toContain ".active"

      it "is set by setActive", ->
        view.setActive "realms"
        view.render()
        expect(view.$el).toContain ".active"




