# [cross-images](https://github.com/vtavernier/cross-images)

Docker images for cross-compiling Rust with native dependencies. This
repository builds [rust](https://hub.docker.com/_/rust/)-based images with the
extra support needed for cross-compiling on unusual targets.

## Targets

Targets are defined in the [`targets`](targets/) folder. The currently defined targets are:

* [`raspberrypi-bookworm`](targets/raspberrypi-bookworm): Raspberry Pi Zero/1 on Raspbian Bookworm

  *Rationale: arm-linux-gnueabihf toolchains are now configured by default to
  use ARMv7, which is only supported by Raspberry Pi 2 and later. This builds a
  arm-linux-gnueabihf toolchain for ARMv6 so we can cross-compile Rust programs
  for those targets.*

* [`raspberrypi-bullseye`](targets/raspberrypi-bullseye): Raspberry Pi Zero/1 on Raspbian Bullseye

  *Rationale: same as above.*

* [`x86_64-bullseye`](targets/x86_64-bullseye): x86_64 native compiler on Debian Bullseye

  *Rationale: for compatibility with other cross compiling images in this
  repository, even if you are targeting your host.*

## Usage

The images built by this repository are compatible with
[cross](https://github.com/rust-embedded/cross). In order to use them, add a
`Cross.toml` file referencing the image for your target as described below.
Then, use `cross` as usual: `cross build --target <TARGET> ...`.

### `raspberrypi-bookworm`

```toml
[target.arm-unknown-linux-gnueabihf]
image = "vtavernier/cross:raspberrypi-bookworm"
```

### `raspberrypi-bullseye`

```toml
[target.arm-unknown-linux-gnueabihf]
image = "vtavernier/cross:raspberrypi-bullseye"
```

### `x86_64-bullseye`

```toml
[target.x86_64-unknown-linux-gnu]
image = "vtavernier/cross:x86_64-bullseye"
```

## Dependencies

All the targets in this repository include the following *common* dependencies:

* sqlite3: available as-is
* python3: feature-gated behind `ENABLE_PYO3=1`

To enable extra features, you need to:

1. Add the `passthrough` setting to `Cross.toml`:

```toml
[build.env]
passthrough = [
    "ENABLE_PYO3"
]
```

2. Set the variable in your environment:

```bash
export ENABLE_PYO3=1
```

3. Build as usual

```bash
cross build
```

## Building the images

A [Makefile](Makefile) is provided to build all images.

```
make
```

## Testing the images

```
make test
```

## Author

Vincent Tavernier <vince.tavernier@gmail.com>
