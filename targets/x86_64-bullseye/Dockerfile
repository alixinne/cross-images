# Create the final image for compiling
FROM docker.io/debian:bullseye-slim

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -qq && apt-get install -y -q --no-install-recommends \
    build-essential pkg-config ca-certificates \
    python3-dev libsqlite3-dev pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# vim: ft=dockerfile:et:sw=2:ts=2
