## All API urls

Read the code (`lib/Play/Route/*.pm`) or try them in the browser for the response format.
Hint: it's usually JSON.

### Personal stuff - auth, settings, etc.

##### GET /auth/twitter

Go to Twitter, obtain login, set `twitter_user` session key and return to `/register` (frontend one, not `/api/register`!)

##### GET /api/current_user

Get current user.

`registered=1` flag means the user is fully registered. Otherwise json still can contain some info (e.g. Twitter).

In addition to the usual user object, the response will contain `settings` and `notifications` fields.

##### POST /api/register

Register the new user login, associate it with the current twitter user, save to db.

`settings` param can contain initial user settings (json-encoded).

##### POST /api/resend_email_confirmation

Resend email confirmation link, duh.

##### GET /api/user/{login}/unsubscribe/{field}

Unset the notification flag `field`.

Requires a `secret` parameter.

Redirects to `/unsubscribe/ok` (or to `/unsubscribe/fail` if secret or something else is wrong).

##### POST /api/register/confirm_email

Params: `login`, `secret`.

Confirm the email ownership.

##### GET /api/fakeuser/{login}

Fake analog of `/api/register`; dev mode only.

`notwitter` cgi param disables fake twitter account generation.

##### GET /api/current_user/settings

Get current user's settings.

##### PUT /api/current_user/settings`

Update current user's settings.

##### POST /api/current_user/settings

Same as `PUT` - both rewrite settings entirely.

##### POST /api/setting/set/{name}/{value}

Set one key/value setting, leaving others intact.

##### POST /api/current_user/dismiss_notification/{id}

Dismiss notification.

##### POST /api/follow_realm/{realm}

Follow a realm (i.e., subscribe to it in news feed).

##### POST /api/unfollow_realm/{realm}

Unfollow a realm.

### Players

##### GET /api/user/{login}

Get any user data.

##### GET /api/user/{login}/pic?s={size}

Get any user's picture.

`size` should be either `small` (24x24) or `normal` (48x48).

##### GET /api/user

Get the list of all users.

`realm` parameter is required.

Options:

* `sort` - any numerical field, e.g. `open_quests`
* `order` - `asc` or `desc`, with `asc` being the default
* `limit`
* `offset`

Special `sort` value `leaderboard` can be used for composite points->open\_quests sorting. It doesn't support order, i.e. it's always descending.

Another special `sort` value `points` can be used to sort by `rp.$realm`.

### Quests

##### POST /api/quest

Add a new quest for the current user.

Parameters:

* `realm`
* `name`

Optional parameters:

* `description`
* `tags`

##### PUT /api/quest/{id}

Update a quest.

Updating quest status with this route is deprecated. Use `POST /api/quest/{id}/{action}` routes instead.

##### POST /api/quest/{id}/close

Complete a quest.

Everyone on a team gets points.

##### POST /api/quest/{id}/reopen

Reopen a quest.

Everyone on a team lose points.

##### POST /api/quest/{id}/abandon

Set open quest's status to `abandoned`.

##### POST /api/quest/{id}/resurrect

Set abandoned quest's status back to `open`.

##### DELETE /api/quest/{id}

Delete a quest.

(actually, set its status to `deleted`; it won't be shown in `/api/quests` and won't be fetchable by its id.)

##### GET /api/quest

Get all quests.

`realm` parameter is required.

Options:

* `limit`
* `offset`
* `order` - `asc` or `desc`, with `desc` being the default
* `sort` - only `leaderboard` value is supported for now, meaning composite likes_count->comments_count sorting
* `user`
* `comment_count`
* `unclaimed` - if true, return unclaimed quests (user='')
* `tags` - filter by tag; only one-tag-per-query filtering is supported now
* `watchers` - filter by watcher; only one-watcher-per-query filtering is supported
* `fmt` - if set to `atom`, return atom instead of json

##### GET /api/quest/{id}

Get one quest.

##### POST /api/quest/{quest_id}/comment

Add a new comment.

##### GET /api/quest/{quest_id}/comment

Get all quest's comments.

##### GET /api/quest/{quest_id}/comment/{comment_id}

Get a single comment.

##### POST /api/quest/{id}/comment/{comment_id}/like

Like a comment.

##### POST /api/quest/{id}/comment/{comment_id}/unlike

Unlike a comment.

##### POST /api/quest/{id}/like

Like a quest.

##### POST /api/quest/{id}/unlike

Unlike a quest.

##### POST /api/quest/{id}/watch

Start watching a quest.

##### POST /api/quest/{id}/unwatch

Stop watching a quest.

##### POST /api/quest/{id}/join

Join a quest. User must be invited first using `/api/quest/{id}/invite` method.

##### POST /api/quest/{id}/leave

Leave a quest. User must be the member of a quest's team.

##### POST /api/quest/{id}/invite

Invite a user (`invitee` param) to the quest.

##### POST /api/quest/{id}/uninvite

Cancel the invitation.

### Realms

##### GET /realm

Get the list of realms.

### Other

##### GET /api/event

Get events, starting from the latest.

`realm` or `for` parameter is required. `realm` filters by realm; `for` gives the personal feed of one user (i.e., list of all events this user is subscribed to).

Other options:

* `limit` (defaults to 100)
* `offset`

##### GET /api/event/atom

Get the Atom feed with 100 last events.

Either `realm` or `for` parameter should be set.

##### GET /api/dev/session/{name}

Get session value. Dev mode only.

## Registration

This is how registration is implemented:

1. JS redirects to `/auth/twitter`
2. `/auth/twitter` redirects to twitter.com
3. twitter.com redirects back to `/auth/twitter`
4. `/auth/twitter`, now with the correct twitter login in user's session, redirects to `/register`
5. JS checks whether the user has both twitter login and service login (using `/api/current_user`); if there's no service login, it shows the registration form
6. User enters his new service login in the registration form, JS calls `/api/register`, and now we're fully registered.

`/api/current_user` is always the key for frontend to check the current authentification status.

## Objects

User:

    {
        _id: ...,
        login: 'blah',
        twitter: {
            screen_name: 'blah',
            profile_image_url: '...'
        },
        realms: ['chaos', 'perl']   # active realms - at least one open or completed quest, populated automatically
        rp: {           # realm points
            'chaos': 3,
            'perl': 2
        },
        fr: ['chaos']   # following realms
    }

Quest:

    {
        _id: ...,
        status: 'open', // or 'closed'
        author: 'blah',
        team: ['blah'], // can be different from author; can contain multiple people; or can be empty
        name: 'quest title',
        description: 'quest description',
        likes: [
            'foo-user',
            'bar-user'
        ],
        realm: 'chaos'
    }

Comment:

    {
        _id: ...,
        body: 'comment body',
        quest_id: ...,
        author: 'foo-user'
    }

Settings:

    {
        email: "president@barackobama.com",
        notify_comments: 1,
        notify_likes: 0,

        // these last two fields are implementation details and probably will be removed
        user: "barack",
        result: "ok"
    }

Event:
    {
        type: 'add-comment', # presence of other fields depend on event type
        author: 'foo',  # event initiator - quest author, comment author, etc.
        realm: 'europe',
        comment_id: 111,
        quest_id: 222,
        comment: { ... },
        quest: { ... },
        invitee: 'bar' # only for 'invite-quest' type
    }
