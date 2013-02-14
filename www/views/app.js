pp.views.App = pp.View.Base.extend({

    initialize: function () {
        this._currentUserView = new pp.views.CurrentUser();
        this._currentUserView.setElement(this.$el.find('.current-user-box'));

        this._markdownConverter = new Markdown.getSanitizingConverter();
        this._markdownConverter.hooks.chain('postSpanGamut', function (text) {
            text = text.replace(/\b(\w+(?:::\w+)+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))/g, '<a href="http://metacpan.org/module/\$1">\$1</a>');
            text = text.replace(/\bcpan:(\w+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))/g, '<a href="http://metacpan.org/module/\$1">\$1</a>');
            return text;
        });
    },

    notify: function (type, message) {
        this.$('.app-view-container').prepend(
            new pp.views.Notify({
                type: type,
                message: message
            }).render().el
        );
    },

    markdownToHtml: function (markdown) {
        return this._markdownConverter.makeHtml(markdown);
    },

    userSettingsDialog: function () {
        this._currentUserView.settingsDialog();
    },

    setPageView: function (page) {
        // the explanation of pattern can be found in this article: http://lostechies.com/derickbailey/2011/09/15/zombies-run-managing-page-transitions-in-backbone-apps/
        // (note that the article is dated - it's pre-0.9.2, Backbone didn't have .listenTo() back then
        if (this._page) {
            this._page.remove(); // TODO - should we remove all subviews too?
        }
        this._page = page;
        this.$('.app-view-container').append(page.$el);

        // (THIS COMMENT IS DEPRECATED. EVERYTHING HAS CHANGED.)
        // we don't call page.render() - our pages render themselves, but sometimes they do it in delayed fashion
        // (i.e., wait for user model to fetch first, and sometimes navigate to the different page based on that)
    }
});
