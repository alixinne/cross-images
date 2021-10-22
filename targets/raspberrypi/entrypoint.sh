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

RUST_TOOLCHAIN=""
for DIR in /src /project; do
  if [ -f "$DIR/rust-toolchain" ]; then
    RUST_TOOLCHAIN="$(cat $DIR/rust-toolchain)"
    rustup toolchain add "$RUST_TOOLCHAIN"
    break
  fi
done

scan_install_target () {
  NEXT_TARGET=0
  for ARG in "$@"; do
    if [ "$ARG" = "--" ]; then
      break
    elif [ "$ARG" = --target ]; then
      NEXT_TARGET=1
    elif [ "$NEXT_TARGET" = 1 ]; then
      NEXT_TARGET=0
      if [ -z "$RUST_TOOLCHAIN" ]; then
        rustup target add "$ARG"
      else
        rustup target add "$ARG" --toolchain "$RUST_TOOLCHAIN"
      fi
    fi
  done
}

if [ "$1" = "sh" ] && [ "$2" = "-c" ]; then
  scan_install_target $3
else
  scan_install_target "$@"
fi

exec "$@"

# vim: ft=bash:et:ts=2:sw=2
