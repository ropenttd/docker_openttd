# BUILD ENVIRONMENT
FROM debian:stable-slim AS ottd_build

ARG OPENTTD_VERSION="14.1"
ARG OPENGFX_VERSION="7.1"

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
    cmake \
    patch \
    libcurl4-openssl-dev \
    libpng-dev \
    zlib1g-dev \
    liblzma-dev \
    liblzo2-dev \
    pkg-config

# Build OpenTTD itself
WORKDIR /tmp/src

RUN git clone https://github.com/OpenTTD/OpenTTD.git . \
    && git fetch --tags \
    && git checkout ${OPENTTD_VERSION}

# Perform the build with the build script (1.11 switches to cmake, so use a script for decision making)
ADD builder.sh /usr/local/bin/builder
RUN chmod +x /usr/local/bin/builder && builder && rm /usr/local/bin/builder

# Add the latest graphics files
## Install OpenGFX
RUN mkdir -p /app/data/baseset/ \
    && cd /app/data/baseset/ \
    && wget -q https://cdn.openttd.org/opengfx-releases/${OPENGFX_VERSION}/opengfx-${OPENGFX_VERSION}-all.zip \
    && unzip opengfx-${OPENGFX_VERSION}-all.zip \
    && tar -xf opengfx-${OPENGFX_VERSION}.tar \
    && rm -rf opengfx-*.tar opengfx-*.zip

# END BUILD ENVIRONMENT
# DEPLOY ENVIRONMENT

FROM debian:stable-slim
ARG OPENTTD_VERSION="14.1"

# Setup the environment and install runtime dependencies
RUN mkdir -p /config \
    && useradd -d /config -u 911 -s /bin/false openttd \
    && apt-get update \
    && apt-get install -y \
    libc6 \
    libcurl4 \
    zlib1g \
    liblzma5 \
    liblzo2-2 \
    nano

WORKDIR /config

# Copy the game data from the build container
COPY --from=ottd_build /app /app

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

# Set default data home directory to force use of /config
ENV XDG_DATA_HOME=/config

# Update path to use binaries in /app
ENV PATH="$PATH:/app"

# Finally, let's run OpenTTD!
USER openttd
CMD [ "/usr/local/bin/entrypoint" ]
