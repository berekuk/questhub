define ["jquery", "vendors/pagedown/Markdown.Sanitizer"], ($, Markdown) ->

    # global variable - let's hope that makeHtml is synchronous...
    realm_id = undefined
    _markdownConverter = new Markdown.getSanitizingConverter()
    _markdownConverter.autoNewLine = true
    _markdownConverter.hooks.chain "postSpanGamut", (text) ->
        text = text.replace /~X(\d+)X\[([x ])\]/g, (wm, m1, m2) ->
            return """<input class="md-task task#{m1}" #{if m2 == "x" then "checked" else ""} type="checkbox">"""

        if realm_id is "perl"
            text = text.replace /\b(\w+(?:::\w+)+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))/g, "<a href=\"http://metacpan.org/module/$1\">$1</a>"
            text = text.replace /\bcpan:([\w-]+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))/g, "<a href=\"http://metacpan.org/module/$1\">$1</a>"
        text = text.replace /(^|[^\w])@(\w+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))/g, "$1<a href=\"/player/$2\">@$2</a>"
        text

    (source, realm) ->
        realm_id = realm
        html = _markdownConverter.makeHtml(source)
        el = $("<div>#{html}</div>")
        el.find("a[href^='/player/']").attr "class", "user-link"
        el.find("a[href^='/player/']").attr "class", "user-link"

        # uncomment to enable task stats
        # TODO - don't show stats in stencils
        #tasks = el.find(".md-task")
        #if tasks.length
        #    totalTasks = tasks.length
        #    checkedTasks = tasks.filter(":checked").length
        #    if checkedTasks == totalTasks
        #        allChecked = true
        #    el.append("""
        #        <div class="md-task-stat #{ if allChecked then "md-task-stat-ready" else "" }">
        #            #{checkedTasks}/#{totalTasks} tasks done.
        #        </div>
        #    """)
        el.html()
