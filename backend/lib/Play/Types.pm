package Play::Types;

use strict;
use warnings;

use Type::Library
    -base,
    -declare => qw(
        Id Login
        ImageSize ImageUpic
        CommentParams
    );
use Type::Utils;
use Types::Standard qw( Str StrMatch Dict );

declare Login, as StrMatch[ qr/^\w+$/ ]; # TODO - limit max size?
declare Id, as StrMatch[ qr/^[0-9a-f]{24}$/ ];

declare ImageSize, as enum [qw/ small normal /];

declare ImageUpic,
    as Dict[small => Str, normal => Str];

declare CommentParams,
    as Dict[
        quest_id => Id,
        body => Str,
        author => Login,
    ];

1;
