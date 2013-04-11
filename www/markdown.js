define([
    'jquery',
    'vendors/pagedown/Markdown.Sanitizer'
], function ($, Markdown) {
    var _markdownConverter = new Markdown.getSanitizingConverter();
    _markdownConverter.hooks.chain('postSpanGamut', function (text) {
        text = text.replace(/\b(\w+(?:::\w+)+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))/g, '<a href="http://metacpan.org/module/\$1">\$1</a>');
        text = text.replace(/\bcpan:(\w+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))/g, '<a href="http://metacpan.org/module/\$1">\$1</a>');

        text = text.replace(/(^|[^\w])@(\w+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))/g, '\$1<a href="/player/\$2">\$2</a>');
        return text;
    });

    return function (source) {
        var html = _markdownConverter.makeHtml(source);
        var el = $('<div>' + html + '</div>');
        el.find("a[href^='/player/']").attr('class', 'label');
        return el.html();
    };
});
