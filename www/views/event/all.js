define([
    'underscore', 'jquery',
    'views/proto/common',
    'text!templates/events.html'
], function (_, $, Common, html) {

    var el = $(html);
    var views = {};

    el.find('script').each(function () {
        var item = $(this);
        var name = item.attr('class');

        views[name] = Common.extend({
            template: _.template(item.text())
        });
    });

    return views;
});
