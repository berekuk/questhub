package Play::Test::Class;

use strict;
use warnings;

use base 'Test::Class';

INIT { Test::Class->runtests } # see https://metacpan.org/module/Test::Class::Load#CUSTOMIZING-TEST-RUNS
1;
