define([
    'models/proto/paged-collection', 'models/quest'
], function (Parent, Quest) {
    return Parent.extend({
        defaultCgi: ['comment_count=1'],
        baseUrl: '/api/quest',
        cgi: ['user', 'status', 'limit', 'offset', 'sort', 'order', 'unclaimed', 'tags'],
        model: Quest,
        initialize: function () {
            Parent.prototype.initialize.apply(this, arguments);

            var order_flag = 1;
            if (this.options.order && this.options.order == 'desc') {
                order_flag = -1;
            }

            if (this.options.sort) {
                if (this.options.sort == 'leaderboard') {
                    // duplicates server-side sorting logic!
                    this.comparator = function(m1, m2) {
                        if (m1.like_count() > m2.like_count()) return -order_flag;
                        if (m2.like_count() > m1.like_count()) return order_flag;

                        if (m1.comment_count() > m2.comment_count()) return -order_flag;
                        if (m2.comment_count() > m1.comment_count()) return order_flag;
                        return 0;
                    };
                }
                else {
                    console.log("oops, unknown sort option " + this.options.sort);
                }
            }
            else {
                this.comparator = function(m1, m2) {
                    if (m1.id > m2.id) return order_flag;
                    if (m2.id > m1.id) return -order_flag;
                    return 0;
                };
            }
        }
    });
});
