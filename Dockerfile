# FORUM multi-stage docker build

# Change release to build, by providing the FORUM_RELEASE build argument to
# your build command:
#
# $ docker build \
#     --build-arg FORUM_RELEASE="open-release/hawthorn.1" \
#     -t forum:hawthorn.1 \
#     .
ARG FORUM_RELEASE=open-release/hawthorn.1
ARG PUMA_RELEASE=3.12.0
ARG UID=1000
ARG GID=1000


# === BASE ===
FROM ruby:2.4.1-slim as base

ARG UID
ARG GID

# Add the non-privileged user that will build and run the application
RUN groupadd --gid ${GID} forum && \
    useradd --uid ${UID} --gid ${GID} --home-dir /app --create-home forum

# Upgrade bundler to the latest release
RUN gem install bundler


# === DOWNLOAD ===
FROM base as downloads

WORKDIR /downloads

# Install required utilities for the download stage
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Download forum sources archive from GitHub releases
ARG FORUM_RELEASE
RUN mkdir forum && \
    wget -O forum.tgz "https://github.com/edx/cs_comments_service/archive/${FORUM_RELEASE}.tar.gz" && \
    tar xzf forum.tgz -C ./forum --strip-components=1


# === BUILDER ===
FROM base as builder

# Install required packages for the build stage
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    git \
    build-essential && \
    rm -rf /var/lib/apt/lists/*

# Working from /app because bundled dependencies will be installed from here
WORKDIR /app

# Copy application sources to install dependencies
COPY --from=downloads --chown=forum:forum downloads/forum ./

# Add puma dependency and update the lockfile
ARG PUMA_RELEASE
RUN bundle inject "puma" "${PUMA_RELEASE}"

# Install dependencies locally in the vendor/bundle directory
RUN bundle install --deployment


# === PRODUCTION ===
FROM base as production

WORKDIR /app

# Copy application sources and dependencies
COPY --from=builder --chown=forum:forum /app ./

# Setup execution environment
ENV BUNDLE_APP_CONFIG=/app/vendor/bundle/ruby/2.4.0/
ENV BUNDLE_PATH=${BUNDLE_APP_CONFIG}

# Switch to an unprivileged user that will run the application
USER forum:forum

# Start the application using bundler
CMD bundle exec puma
