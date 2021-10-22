#!/bin/bash

set -eu

SOURCE_BASE="$(dirname "$BASH_SOURCE[0]")"
TARGET_NAME="$(basename "$SOURCE_BASE")"
cd "$SOURCE_BASE"
. ../common.sh

# Rust target
TARGET=x86_64-unknown-linux-gnu

# C test
#  We're using Python for this test
export ENABLE_PYO3=1
test_rust_git \
	"git@github.com:vtavernier/blog-cross-rpi.git" \
	"blog-cross-rpi" \
	"--all-features"

# vim: ft=bash:et:ts=2:sw=2
