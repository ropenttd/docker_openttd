# BUILD ENVIRONMENT
FROM debian:latest AS build

ARG OPENTTD_VERSION="1.8.0"
ARG OPENGFX_VERSION="0.5.4"

# Get things ready
RUN mkdir -p /config \
    && mkdir /tmp/src

# Install build dependencies
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
WORKDIR /tmp/src

RUN git clone https://github.com/OpenTTD/OpenTTD.git . \
    && git fetch --tags \
    && git checkout ${OPENTTD_VERSION}

RUN /tmp/src/configure \
    --enable-dedicated \
    --binary-dir=bin \
    --data-dir=data \
    --prefix-dir=/app \
    --personal-dir=/ \
    —-enable-debug

RUN make -j"$(nproc)" \
    && make install
    
# Add the latest graphics files
## Install OpenGFX
RUN mkdir -p /app/data/baseset/ \
    && cd /app/data/baseset/ \
    && wget -q http://bundles.openttdcoop.org/opengfx/releases/${OPENGFX_VERSION}/opengfx-${OPENGFX_VERSION}.zip \
    && unzip opengfx-${OPENGFX_VERSION}.zip \
    && tar -xf opengfx-${OPENGFX_VERSION}.tar \
    && rm -rf opengfx-*.tar opengfx-*.zip



# END BUILD ENVIRONMENT
# DEPLOY ENVIRONMENT

FROM debian:latest
MAINTAINER duck. <me@duck.me.uk>

# Setup the environment and install runtime dependencies
RUN mkdir -p /config \
    && useradd -d /config -u 911 -s /bin/false openttd
    && apt-get update \
    && apt-get install -y \
    libc6 \
    zlib1g \
    liblzma5 \
    liblzo2-2
    
WORKDIR /config

# Copy the game data from the build container
COPY --from=build /app /app

# Add the entrypoint
ADD entrypoint.sh /usr/local/bin/entrypoint
    
# Expose the volume
RUN chown -R openttd:openttd /config /app
VOLUME /config

# Expose the gameplay port
EXPOSE 3979/tcp
EXPOSE 3979/udp

# Expose the admin port
EXPOSE 3977/tcp

# Finally, let's run OpenTTD!
USER openttd
CMD /usr/local/bin/entrypoint