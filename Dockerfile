# FORUM multi-stage docker build

# Change release to build, by providing the FORUM_RELEASE build argument to
# your build command:
#
# $ docker build \
#     --build-arg FORUM_RELEASE="open-release/hawthorn.2" \
#     -t forum:hawthorn.2 \
#     .
ARG FORUM_RELEASE=open-release/hawthorn.2

# === BASE ===
FROM ubuntu:16.04 as base


# === DOWNLOAD ===
FROM base as downloads

WORKDIR /downloads

# Install curl
RUN apt-get update && \
    apt-get install -y curl

# Download forum source
ARG FORUM_RELEASE
RUN curl -sLo forum.tgz https://github.com/edx/cs_comments_service/archive/$FORUM_RELEASE.tar.gz && \
    tar xzf forum.tgz

FROM base as final

WORKDIR /app

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y git curl wget rubygems gnupg g++
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys E206C29FBF04FF17
RUN curl https://raw.githubusercontent.com/wayneeseguin/rvm/stable/binscripts/rvm-installer| bash -s stable
RUN /bin/bash -c 'source /usr/local/rvm/scripts/rvm && rvm install ruby-2.4.1'

COPY --from=downloads /downloads/cs_comments_service* .

RUN /bin/bash -c "echo \"gem 'puma'\" >> Gemfile && \
    source /usr/local/rvm/scripts/rvm && \
    gem install bundle && \
    bundle install"

ENV rvm_bin_path="/usr/local/rvm/bin"
ENV GEM_HOME="/usr/local/rvm/gems/ruby-2.4.1@cs_comments_service"
ENV IRBRC="/usr/local/rvm/rubies/ruby-2.4.1/.irbrc"
ENV MY_RUBY_HOME="/usr/local/rvm/rubies/ruby-2.4.1"
ENV _system_type="Linux"
ENV rvm_path="/usr/local/rvm"
ENV rvm_prefix="/usr/local"
ENV PATH="/usr/local/rvm/gems/ruby-2.4.1@cs_comments_service/bin:/usr/local/rvm/gems/ruby-2.4.1@global/bin:/usr/local/rvm/rubies/ruby-2.4.1/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV _system_arch="x86_64"
ENV _system_version="16.04"
ENV rvm_version="1.29.4 (latest)"
ENV rvm_pretty_print_flag="auto"
ENV rvm_ruby_string="ruby-2.4.1"
ENV GEM_PATH="/usr/local/rvm/gems/ruby-2.4.1@cs_comments_service:/usr/local/rvm/gems/ruby-2.4.1@global"
ENV rvm_delete_flag="0"
ENV RUBY_VERSION="ruby-2.4.1"
ENV _system_name="Ubuntu"

CMD puma
