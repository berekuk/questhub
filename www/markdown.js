define([
    'jquery',
    'vendors/pagedown/Markdown.Sanitizer'
], function ($, Markdown) {

    // global variable - let's hope that makeHtml is synchronous...
    var realm_prefix;
    var realm_id;

    var _markdownConverter = new Markdown.getSanitizingConverter();
    _markdownConverter.hooks.chain('postSpanGamut', function (text) {

        if (realm_id == 'perl') {
            text = text.replace(/\b(\w+(?:::\w+)+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))/g, '<a href="http://metacpan.org/module/\$1">\$1</a>');
            text = text.replace(/\bcpan:(\w+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))/g, '<a href="http://metacpan.org/module/\$1">\$1</a>');
        }

        text = text.replace(/(^|[^\w])@(\w+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))/g, '\$1<a href="' + realm_prefix + '/player/\$2">\$2</a>');
        return text;
    });

    return function (source, realm) {
        realm_id = realm;
        realm_prefix = (realm ? '/' + realm : '');

        var html = _markdownConverter.makeHtml(source);
        var el = $('<div>' + html + '</div>');
        el.find("a[href^='/player/']").attr('class', 'label');
        el.find("a[href^='" + realm_prefix + "/player/']").attr('class', 'label');
        return el.html();
    };
});
