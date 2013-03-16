define([
    'vendors/pagedown/Markdown.Sanitizer'
], function (Markdown) {
    var _markdownConverter = new Markdown.getSanitizingConverter();
    _markdownConverter.hooks.chain('postSpanGamut', function (text) {
        text = text.replace(/\b(\w+(?:::\w+)+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))/g, '<a href="http://metacpan.org/module/\$1">\$1</a>');
        text = text.replace(/\bcpan:(\w+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))/g, '<a href="http://metacpan.org/module/\$1">\$1</a>');
        return text;
    });

    return function (source) {
        return _markdownConverter.makeHtml(source);
    };
});
