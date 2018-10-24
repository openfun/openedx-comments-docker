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
FROM ruby:2.4.1 as base


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
FROM builder as production

# Start the application using bundler
CMD bundle exec puma
