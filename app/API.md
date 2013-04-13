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

##### POST /api/current_user/dismiss_notification/{id}

Dismiss notification.

### Players

##### GET /api/user/{login}

Get any user data.

##### GET /api/user

Get the list of all users.

Options:

* `sort` - any numerical field, e.g. `open_quests` or `points`
* `order` - `asc` or `desc`, with `asc` being the default
* `limit`
* `offset`

Special `sort` value `leaderboard` can be used for composite points->open_quests sorting. It doesn't support order, i.e. it's always descending.

##### GET /api/user_count

Get a total number of users.

Options:

* `user` - filter by user
* `status` - filter by status (`deleted` status is forbidden)
* `comment_count` - add `comment_count` field to each returned quest
* `limit`
* `offset`

### Quests

##### POST /api/quest

Add a new quest for the current user.

##### PUT /api/quest/{id}

Update a quest.

##### DELETE /api/quest/{id}

Delete a quest.

(actually, set its status to `deleted`; it won't be shown in `/api/quests` and won't be fetchable by its id.)

##### GET /api/quest

Get all quests.

Options:

* `limit`
* `offset`
* `order` - `asc` or `desc`, with `asc` being the default
* `sort` - only `leaderboard` value is supported for now, meaning composite likes_count->comments_count sorting
* `user`
* `comment_count`
* `unclaimed` - if true, return unclaimed quests (user='')
* `tags` - filter by tag; only one-tag-per-query filtering is supported now

##### GET /api/quest?user={login}

Get all quests of a given user.

##### GET /api/quest?status={status}

Get all quests with a given status.

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

Join a quest. Quest must be unclaimed.

##### POST /api/quest/{id}/leave

Leave a quest. You must have this quest claimed at the moment of leaving.

### Other

##### GET /api/event

Get events, starting from the latest.

Options:

* `limit` (defaults to 100)
* `offset`

##### GET /api/event/atom

Get the Atom feed with 100 last events.

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
        points: 123,
        twitter: {
            screen_name: 'blah'
        }
    }

Quest:

    {
        _id: ...,
        status: 'open', // or 'closed'
        author: 'blah',
        user: 'blah',   // can be different from author or even empty
        name: 'quest title',
        type: 'bug'     // or 'blog', or 'feature'
        likes: [
            'foo-user',
            'bar-user'
        ]
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
