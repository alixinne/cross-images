# Build a cross-compiler matching the one in the current Raspbian Bullseye
FROM docker.io/debian:bullseye-slim AS build

ARG GCC_MIRROR=https://ftpmirror.gnu.org/
ARG BINUTILS_VERSION=2.35.2
ARG GCC_VERSION=10.2.0
ARG GLIBC_VERSION=2.31

# Fetch build dependencies
RUN DEBIAN_FRONTEND=noninteractive \
       apt-get update -qq \
    && apt-get install -q -y --no-install-recommends \
          build-essential wget git xz-utils \
          gawk bison python3 rsync ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Fetch sources
RUN mkdir -p /opt/cross-build \
    && cd /opt/cross-build \
    && echo "Getting binutils-${BINUTILS_VERSION}" \
    && wget -q ${GCC_MIRROR}/binutils/binutils-${BINUTILS_VERSION}.tar.xz \
    && echo "Getting gcc-${GCC_VERSION}" \
    && wget -q ${GCC_MIRROR}/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz \
    && echo "Getting glibc-${GLIBC_VERSION}" \
    && wget -q ${GCC_MIRROR}/glibc/glibc-${GLIBC_VERSION}.tar.xz \
    && echo "Extracting binutils-${BINUTILS_VERSION}" \
    && tar -xf binutils-${BINUTILS_VERSION}.tar.xz \
    && echo "Extracting gcc-${GCC_VERSION}" \
    && tar -xf gcc-${GCC_VERSION}.tar.xz \
    && echo "Extracting glibc-${GLIBC_VERSION}" \
    && tar -xf glibc-${GLIBC_VERSION}.tar.xz \
    && rm *.tar.xz \
    && cd /opt/cross-build/gcc-${GCC_VERSION} \
    && ./contrib/download_prerequisites \
    && echo "Extracting linux kernel headers" \
    && cd /opt/cross-build \
    && wget -q -O linux.tar.gz https://github.com/raspberrypi/linux/archive/refs/heads/rpi-5.10.y.tar.gz \
    && tar --strip-components=1 --one-top-level=linux -xf linux.tar.gz \
    && cd linux \
    && make KERNEL=kernel7 ARCH=arm INSTALL_HDR_PATH=/opt/cross/arm-linux-gnueabihf headers_install

# Add the (future) cross-compiler to the PATH
ENV PATH=/opt/cross/bin:${PATH}

# Configure binutils and gcc
RUN cd /opt/cross-build \
    && mkdir binutils-build gcc-build glibc-build \
    && (cd binutils-build && ../binutils-${BINUTILS_VERSION}/configure --prefix=/opt/cross --target=arm-linux-gnueabihf --with-arch=armv6 --with-fpu=vfp --with-float=hard --disable-multilib) \
    && (cd gcc-build && ../gcc-${GCC_VERSION}/configure --prefix=/opt/cross --target=arm-linux-gnueabihf --with-arch=armv6 --with-fpu=vfp --with-float=hard --disable-multilib --enable-languages=c,c++)

# Build binutils
RUN cd /opt/cross-build/binutils-build && make -j$(nproc) && make install

# Build gcc base
RUN cd /opt/cross-build \
    && (cd gcc-build && make -j$(nproc) all-gcc && make install-gcc)

# Deploy patches for glibc
COPY patches /opt/cross-build/patches

#_Build glibc
RUN cd /opt/cross-build/glibc-build \
    && for PATCH in /opt/cross-build/patches/glibc-*.patch; do (cd ../glibc-${GLIBC_VERSION} && patch -p1 <$PATCH); done \
    && ../glibc-${GLIBC_VERSION}/configure --prefix=/opt/cross/arm-linux-gnueabihf --build=$MACHTYPE --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf --with-arch=armv6 --with-fpu=vfp --with-float=hard --with-headers=/opt/cross/arm-linux-gnueabihf/include --disable-multilib libc_cv_forced_unwind=yes \
    && make install-bootstrap-headers=yes install-headers \
    && make -j$(nproc) csu/subdir_lib \
    && install csu/crt1.o csu/crti.o csu/crtn.o /opt/cross/arm-linux-gnueabihf/lib \
    && arm-linux-gnueabihf-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o /opt/cross/arm-linux-gnueabihf/lib/libc.so \
    && touch /opt/cross/arm-linux-gnueabihf/include/gnu/stubs.h

# Build libgcc
RUN cd /opt/cross-build/gcc-build \
    && make -j$(nproc) all-target-libgcc \
    && make install-target-libgcc

# Finish building glibc
RUN cd /opt/cross-build/glibc-build \
    && make -j$(nproc) \
    && make install

# Install the stripped version
RUN cd /opt/cross-build/gcc-build \
    && echo "#ifndef PATH_MAX\n#define PATH_MAX 4096\n#endif\n" >/opt/cross-build/gcc-${GCC_VERSION}/libsanitizer/asan/asan_linux.cpp.hdr \
    && mv /opt/cross-build/gcc-${GCC_VERSION}/libsanitizer/asan/asan_linux.cpp /opt/cross-build/gcc-${GCC_VERSION}/libsanitizer/asan/asan_linux.cpp.old \
    && cat /opt/cross-build/gcc-${GCC_VERSION}/libsanitizer/asan/asan_linux.cpp.hdr /opt/cross-build/gcc-${GCC_VERSION}/libsanitizer/asan/asan_linux.cpp.old > /opt/cross-build/gcc-${GCC_VERSION}/libsanitizer/asan/asan_linux.cpp \
    && make -j$(nproc) \
    && make install-strip

# Fetch native dependencies using the Balena images
FROM docker.io/balenalib/raspberry-pi-debian:bullseye-build AS target-base
FROM docker.io/balenalib/raspberry-pi-debian:bullseye-build AS target

# See https://github.com/GoogleContainerTools/kaniko/issues/1556#issuecomment-1475814975
COPY --from=target-base /bin/sh /bin/sh.real

ENV QEMU_EXECVE=1

RUN ["cross-build-start"]

# Install common native dependencies
RUN install_packages python3-dev libsqlite3-dev

RUN ["cross-build-end"]

# Create the final image for cross-compiling
FROM docker.io/debian:bullseye-slim

# We want to access the cross-compilers directly
ENV PATH=/opt/cross/bin:${PATH}

# Fetch build dependencies
RUN DEBIAN_FRONTEND=noninteractive \
       apt-get update -qq \
    && apt-get install -q -y --no-install-recommends \
          build-essential pkg-config ca-certificates \
          git python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Deploy native dependencies
COPY --from=target /usr/include /opt/cross/include
COPY --from=target /usr/lib /opt/cross/lib
COPY --from=target /usr/share /opt/cross/share

# Deploy cross-compiler from first step
COPY --from=build /opt/cross /opt/cross

# These symbolic links fix linking to cross dependencies
RUN ln -s /opt/cross/lib/arm-linux-gnueabihf /lib \
    && ln -s /opt/cross/lib/arm-linux-gnueabihf /usr/lib \
    && ln -s /opt/cross/lib/ld-linux-armhf.so.3 /lib \
    # Fix pyo3 looking for _sysconfig in PYO3_CROSS_LIB_DIR
    && ln -s /opt/cross/lib/python* /opt/cross/lib/arm-linux-gnueabihf

# Set the cross-compiler for Rust's target
ENV CARGO_TARGET_ARM_UNKNOWN_LINUX_GNUEABIHF_LINKER=arm-linux-gnueabihf-gcc \
    CARGO_TARGET_ARM_UNKNOWN_LINUX_GNUEABIHF_AR=arm-linux-gnueabihf-ar \
    CC_arm_unknown_linux_gnueabihf=arm-linux-gnueabihf-gcc \
    CXX_arm_unknown_linux_gnueabihf=arm-linux-gnueabihf-g++

# Deploy entrypoint
COPY entrypoint.sh /
CMD ["/bin/bash"]
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /src

# vim: ft=dockerfile:et:sw=2:ts=2
