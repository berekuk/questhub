package Play::Types;

use strict;
use warnings;

use Type::Library
    -base,
    -declare => qw( Login ImageSize );
use Type::Utils;
use Types::Standard qw( Str );

declare Login,
    as Str,
    where { /^\w+$/ }; # TODO - limit max size?

declare ImageSize, as enum [qw/ small normal /];

1;
