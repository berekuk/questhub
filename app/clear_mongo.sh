#!/bin/sh

(echo 'use play'; cat mongo_setup) | mongo
(echo 'use play_test'; cat mongo_setup) | mongo
