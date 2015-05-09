#!/bin/sh

perl -I/play/backend/lib -e 'use Play::Mongo; Play::Mongo->db->eval("db.$_.drop()") for qw/posts users sessions comments events realms/'
perl -I/play/backend/lib -e 'use Play::DB qw(db); db->ensure_indices; db->realms->reset_to_initial'
