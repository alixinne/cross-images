#!/bin/bash

if [ -z "$PKG_CONFIG_ALLOW_CROSS" ]; then
  export PKG_CONFIG_ALLOW_CROSS=1
fi

if [ -z "$PKG_CONFIG_PATH" ]; then
  export PKG_CONFIG_PATH=/opt/cross/lib/arm-linux-gnueabihf/pkgconfig
fi

if [ -z "$CPATH" ]; then
  export CPATH=/opt/cross/include
fi

if [ "$ENABLE_PYO3" = "1" ]; then
  export PYO3_CROSS_PYTHON_VERSION=3.9
  export PYO3_CROSS_LIB_DIR=/opt/cross/lib/arm-linux-gnueabihf
  export RUSTFLAGS="-C link-arg=-L/opt/cross/lib/arm-linux-gnueabihf -C link-arg=-lexpat -C link-arg=-lz"
fi

if [ "$@" = "" ]; then
  exec /bin/bash
else
  exec "$@"
fi

# vim: ft=bash:et:ts=2:sw=2
