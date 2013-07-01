define ["models/comment", "views/comment/any"], (CommentModel, CommentText) ->
  describe "comments render", ->
    model = new CommentModel(
      body: "aaa"
      ts: 1363395653
      body_html: "aaa\n"
      quest_id: "5143c351dd3d73910c00000e"
      author: "ooo"
      type: "text"
    )
    view = new CommentText(model: model)
    view.render()
    it "comment body", ->
      expect(view.$el.html()).toContain "aaa"

    it "comment author", ->
      expect(view.$el.html()).toContain "ooo"



