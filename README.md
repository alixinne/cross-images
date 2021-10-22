# [cross-images](https://github.com/vtavernier/cross-images)

Docker images for cross-compiling Rust with native dependencies. This
repository builds [rust](https://hub.docker.com/_/rust/)-based images with the
extra support needed for cross-compiling on unusual targets.

## Targets

Targets are defined in the [`targets`](targets/) folder. The currently defined targets are:

* [`raspberrypi`](targets/raspberrypi): Raspberry Pi Zero/1

  *Rationale: arm-linux-gnueabihf toolchains are now configured by default to
  use ARMv7, which is only supported by Raspberry Pi 2 and later. This builds a
  arm-linux-gnueabihf toolchain for ARMv6 so we can cross-compile Rust programs
  for those targets.*

## Usage

The images built by this repository are compatible with
[cross](https://github.com/rust-embedded/cross). In order to use them, add a
`Cross.toml` file referencing the image for your target as described below.
Then, use `cross` as usual: `cross build --target <TARGET> ...`.

### `raspberrypi`

```toml
[target.arm-unknown-linux-gnueabihf]
image = "vtavernier/cross:raspberrypi"
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

See the [tests](tests/) folder.

## Author

Vincent Tavernier <vince.tavernier@gmail.com>
