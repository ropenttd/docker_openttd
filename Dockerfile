FROM debian:latest
MAINTAINER Andrew Leach <me@duck.me.uk>

ARG OPENTTD_VERSION="1.8.0"
ARG OPENGFX_VERSION="0.5.4"

# Get things ready
RUN mkdir -p /config \
    && mkdir /tmp/build \
    && useradd -d /config -u 911 -s /bin/false openttd \
    && chown -R openttd:openttd /config

# Install some build dependencies (we remove these later to save space)
RUN apt-get update && \
    apt-get install -y \
    unzip \
    wget \
    git \
    g++ \
    make \
    patch \
    zlib1g-dev \
    liblzma-dev \
    liblzo2-dev \
    pkg-config

# Build OpenTTD itself
WORKDIR /tmp/build

RUN git clone https://github.com/OpenTTD/OpenTTD.git . \
    && git fetch --tags \
    && git checkout ${OPENTTD_VERSION}

RUN /tmp/build/configure \
    --enable-dedicated \
    --binary-dir=bin \
    --personal-dir=/ \
    —-enable-debug

RUN make -j2 \
    && make install

## Install OpenGFX
RUN mkdir -p /usr/local/share/games/openttd/baseset/ \
    && cd /usr/local/share/games/openttd/baseset/ \
    && wget -q http://bundles.openttdcoop.org/opengfx/releases/${OPENGFX_VERSION}/opengfx-${OPENGFX_VERSION}.zip \
    && unzip opengfx-${OPENGFX_VERSION}.zip \
    && tar -xf opengfx-${OPENGFX_VERSION}.tar \
    && rm -rf opengfx-*.tar opengfx-*.zip

# Add the entrypoint
ADD entrypoint.sh /usr/local/bin/entrypoint

# Expose the volume
VOLUME /config

# Expose the gameplay port
EXPOSE 3979/tcp
EXPOSE 3979/udp

# Expose the admin port
EXPOSE 3977/tcp

# Tidy up after ourselves
# note: we don't remove libraries and compilers otherwise bad linking things happen
RUN apt-get remove -y \
    make \
    patch \
    git \
    wget

RUN rm -r /tmp/build

# Finally, let's run OpenTTD!
USER openttd
WORKDIR /config
CMD /usr/local/bin/entrypoint
