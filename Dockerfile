# FORUM multi-stage docker build

# Change release to build, by providing the FORUM_RELEASE build argument to
# your build command:
#
# $ docker build \
#     --build-arg FORUM_RELEASE="open-release/hawthorn.1" \
#     -t forum:hawthorn.1 \
#     .
ARG FORUM_RELEASE=open-release/hawthorn.1

# === BASE ===
FROM ruby:2.4.1-slim as base


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
    wget -O forum.tgz https://github.com/edx/cs_comments_service/archive/$FORUM_RELEASE.tar.gz && \
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

# Upgrade bundler to the latest release
RUN gem install bundler

# Working from /app because bundled dependencies will be installed from here
WORKDIR /app

# Copy application sources to install dependencies
COPY --from=downloads /downloads/forum ./

# Add puma dependency and update the lockfile
RUN echo "gem 'puma'" >> Gemfile && \
    bundle lock

# Install dependencies in the vendor/bundle directory
RUN bundle install --deployment

# === PRODUCTION ===
FROM base as production

WORKDIR /app

# Copy application sources and dependencies
COPY --from=builder /app ./

# FIXME: Re-installing dependencies seems to "re-configure" bundler. After this
# fast step (nothing is re-installed), the bundler environment seems properly
# set and binaries can be executed via "bundle exec".
RUN gem install bundler && \
    bundle install --deployment

# Start the application using bundler
CMD bundle exec puma
