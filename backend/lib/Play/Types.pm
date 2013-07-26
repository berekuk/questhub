package Play::Types;

use strict;
use warnings;

use Type::Library
    -base,
    -declare => qw(
        Id Login
        Realm RealmName
        StencilPoints
        ImageSize ImageUpic
        CommentParams
    );
use Type::Utils;
use Types::Standard qw( Str StrMatch Dict Int );

declare Login, as StrMatch[ qr/^\w{1,16}$/ ];
declare Realm, as StrMatch[ qr/^\w{1,16}$/ ];
declare RealmName, as StrMatch[ qr/^.{1,16}$/ ];
declare Id, as StrMatch[ qr/^[0-9a-f]{24}$/ ];

declare StencilPoints,
    as Int,
    where { $_ == 1 or $_ == 2 or $_ == 3 };

declare ImageSize, as enum([qw/ small normal /]);

declare ImageUpic,
    as Dict[small => Str, normal => Str];

declare CommentParams,
    as (
        Dict[
            entity => enum([qw( quest stencil )]),
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

1;
