define ["models/proto/paged-collection", "models/quest"], (Parent, Quest) ->
    class extends Parent
        defaultCgi: ["comment_count=1"]
        baseUrl: "/api/quest"
        cgi: ["user", "status", "limit", "offset", "sort", "order", "unclaimed", "tags", "watchers", "realm"]
        model: Quest
        initialize: ->
            super
            order_flag = 1
            order_flag = -1  if @options.order and @options.order is "desc"
            if @options.sort
                if @options.sort is "leaderboard"

                    # duplicates server-side sorting logic!
                    @comparator = (m1, m2) ->
                        return -order_flag  if m1.like_count() > m2.like_count()
                        return order_flag  if m2.like_count() > m1.like_count()
                        return -order_flag  if m1.comment_count() > m2.comment_count()
                        return order_flag  if m2.comment_count() > m1.comment_count()
                        0
                else if @options.sort is "manual"

                    # duplicates server-side sorting logic!
                    @comparator = (m1, m2) ->
                        o1 = m1.get("order")
                        o2 = m2.get("order")
                        t1 = m1.get("ts")
                        t2 = m2.get("ts")
                        if o1 and o2
                            if o1 < o2
                                -1
                            else if o1 > o2
                                1
                            else
                                0
                        else if o1
                            1
                        else if o2
                            -1
                        else
                            if t1 < t2
                                1
                            else if t1 > t2
                                -1
                            else
                                0
                else
                    console.log "oops, unknown sort option " + @options.sort
            else
                @comparator = (m1, m2) ->
                    return order_flag  if m1.id > m2.id
                    return -order_flag  if m2.id > m1.id
                    0

        saveManualOrder: (ids) ->
            mixpanel.track "set order"
            $.post "/api/quest/set_manual_order",
                "quest_ids[]": ids



