package Play::Types;

use strict;
use warnings;

use Type::Library
    -base,
    -declare => qw( Login ImageSize ImageUpic );
use Type::Utils;
use Types::Standard qw( Str Dict );

declare Login,
    as Str,
    where { /^\w+$/ }; # TODO - limit max size?

declare ImageSize, as enum [qw/ small normal /];

declare ImageUpic,
    as Dict[small => Str, normal => Str];

1;
