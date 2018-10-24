FROM fundocker/edxapp:hawthorn.1-2.0.1

ARG DEMO_COURSE_URL=https://github.com/edx/edx-demo-course/archive/open-release/hawthorn.1.tar.gz
ARG DOCKERIZE_VERSION=v0.6.1

# Switch back to a priviledged user to perform base installation
USER root:root

# FIXME: as mentionned in openfun/openedx-docker and edx/edx-platform bug
# tracker, this webpack-stats.json is required both in production and
# development in a static directory 😢
RUN mkdir /edx/app/edxapp/staticfiles && \
    cp /edx/app/edxapp/edx-platform/common/static/webpack-stats.json /edx/app/edxapp/staticfiles/

# Install dockerize to wait for mysql before running the container command
# (and prevent connection issues)
RUN python -c "import requests;open('dockerize-linux-amd64.tar.gz', 'wb').write(requests.get('https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz', allow_redirects=True).content)" && \
    tar -C /usr/local/bin -xzvf dockerize-linux-amd64.tar.gz && \
    rm dockerize-linux-amd64.tar.gz

# Download a demo course in the container itself so that we can import it
# further without having to deal with volume permissions, etc.
RUN mkdir -p /edx/demo/course && \
    python -c "import requests;open('/edx/demo/course.tgz', 'wb').write(requests.get('${DEMO_COURSE_URL}', allow_redirects=True).content)" && \
    cd /edx/demo && \
    tar xzf course.tgz -C ./course --strip-components=1
