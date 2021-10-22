set -eu

if hash podman >/dev/null 2>&1; then
  DOCKER=podman
else
  DOCKER=docker
fi

test_c_prog () {
  # Fetch parameters
  SOURCE="$1"
  COMMAND="$2"
  NAME="${3:-main}"

  # Create a temporary directory
  DIR="$(mktemp -d)"

  # Deploy source
  echo "$SOURCE" >"$DIR/$NAME.c"
  SOURCE_IN="/src/$NAME.c"
  BINARY_OUT="/src/$NAME"

  # Run compilation
  rm -f "$NAME-$TARGET_NAME"
  if $DOCKER run -v "$DIR:/src:z" --rm -it \
    -e ENABLE_PYO3=${ENABLE_PYO3:-} \
    -e SOURCE_IN="$SOURCE_IN" \
    -e BINARY_OUT="$BINARY_OUT" \
    vtavernier/cross:$TARGET_NAME \
    /bin/bash -c "$COMMAND"; then
      echo -e "\e[32mCompilation succeeded\e[0m" >&2
      mv "$DIR/$NAME" "$NAME-$TARGET_NAME"
    else
      echo -e "\e[32mCompilation failed with code: $?\e[0m" >&2
  fi

  # Cleanup
  rm -rf "$DIR"
}

test_rust_git () {
  # Fetch parameters
  SOURCE="$1"
  NAME="$2"
  ARGS="${3:-}"

  # Create a temporary directory
  DIR="$(mktemp -d)"

  # Deploy source
  git clone --depth=1 "$SOURCE" "$DIR"

  # Create Cross.toml file
  cat >"$DIR/Cross.toml" <<EOT
[build.env]
passthrough = ["ENABLE_PYO3"]

[target.$TARGET]
image = "vtavernier/cross:$TARGET_NAME"
EOT

  # Run compilation
  rm -f "$NAME-$TARGET_NAME"
  if (cd "$DIR" && cross build --target $TARGET $ARGS); then
    echo -e "\e[32mCompilation succeeded\e[0m" >&2
    mv "$DIR/target/$TARGET/debug/$NAME" "$NAME-$TARGET_NAME"
  else
    echo -e "\e[32mCompilation failed with code: $?\e[0m" >&2
  fi

  # Cleanup
  if [ "${NO_CLEANUP:-}" != 1 ]; then
    rm -rf "$DIR"
  fi
}

# vim: ft=bash:et:ts=2:sw=2
