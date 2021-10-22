# Create the final image for compiling
FROM docker.io/rust:bullseye

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -qq && apt-get install -y -q --no-install-recommends \
    python3-dev libsqlite3-dev build-essential pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# vim: ft=dockerfile:et:sw=2:ts=2
