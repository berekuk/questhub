package Play::DB::Images::StorageRole;

use 5.014;
use Moo::Role;

requires 'store';
requires 'load';
requires 'has_key';

1;
