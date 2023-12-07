#!/bin/bash

set -eu

SOURCE_BASE="$(dirname "$BASH_SOURCE[0]")"
TARGET_NAME="$(basename "$SOURCE_BASE")"
cd "$SOURCE_BASE"
. ../common.sh

# C test
#  We're using Python for this test
export ENABLE_PYO3=1
test_c_prog \
	$'#include <Python.h>\nint main() { Py_Initialize(); PyRun_SimpleString("print(\'Hello\')"); Py_Finalize(); return 0; }' \
	'arm-linux-gnueabihf-gcc -o$BINARY_OUT $SOURCE_IN -I/opt/cross/include/python3.9 -L/opt/cross/lib/arm-linux-gnueabihf -Wl,-rpath-link,/opt/cross/lib/arm-linux-gnueabihf -lexpat -lz $(pkg-config --define-prefix python3-embed --cflags --libs)' \

# vim: ft=bash:et:ts=2:sw=2
