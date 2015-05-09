#!/bin/bash

set -e
erb ./config.yml.erb >./config.yml
