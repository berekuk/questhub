package Play::Types;

use strict;
use warnings;

use Type::Library
    -base,
    -declare => qw(
        Id Login Tag
        NonEmptyStr
        Realm RealmName
        Entity
        StencilPoints
        ImageSize ImageUpic
        CommentParams
        NewsFeedTab
    );
use Type::Utils;
use Types::Standard qw( Str StrMatch Dict Int );

declare Login, as StrMatch[ qr/^\w{1,16}$/ ];
declare Realm, as StrMatch[ qr/^\w{1,16}$/ ];
declare RealmName, as StrMatch[ qr/^.{1,16}$/ ];
declare Id, as StrMatch[ qr/^[0-9a-f]{24}$/ ];
declare Tag, as StrMatch[ qr/^[\w-]{1,24}$/ ];

declare NonEmptyStr,
    as Str,
    where { length $_ };

declare StencilPoints,
    as Int,
    where { $_ == 1 or $_ == 2 or $_ == 3 };

declare ImageSize, as enum([qw/ small normal /]);

declare ImageUpic,
    as Dict[small => Str, normal => Str];

declare Entity,
    as enum([qw( quest stencil )]);

declare CommentParams,
    as (
        Dict[
            entity => Entity,
            eid => Id,
            author => Login,
#            type => enum['text'], # default?
            body => Str,
        ] |
        Dict[
            entity => enum([qw( quest )]),
            eid => Id,
            author => Login,
            type => enum([qw( like close reopen abandon resurrect leave join )]),
        ] |
        Dict[
            entity => enum([qw( quest )]),
            eid => Id,
            author => Login,
            type => enum([qw( invite )]),
            invitee => Login,
        ]
    );

declare NewsFeedTab,
    as enum([qw( default users realms watched global )]);

1;
