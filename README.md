# Open edX Comment Service Docker image

A handcrafted Docker image for the [Open edX comment
service](https://github.com/edx/cs_comments_service) (_aka_ forum).

## Installation

To add this image to your Open edX stack, pull our image from DockerHub (see
[fundocker/forum](https://hub.docker.com/r/fundocker/forum/)):

```bash
$ docker pull fundocker/forum
```

## Getting started

First things first, if you plan to work on the project itself, you will need to
clone this repository:

```
$ git clone git@github.com:openfun/openedx-comments-docker.git
```

Once the project has been cloned on your machine, you will need to build the
docker image for the forum and setup a development environment that includes all
required services up and running (more on this later):

```bash
$ cd openedx-comments-docker
$ make bootstrap
```

If everything went well, you should now be able to access the following
services:

- Forum: https://localhost:9292
- Open edX LMS: http://localhost:8000
- MailCatcher: http://localhost:1080

with the following credentials (for the LMS):

```
email: admin@foex.edu
password: openedx-rox
```

## Developer guide

Once the project has been bootstrapped (see "Getting started" section), to start
working on the project, use:

```
$ make dev
```

You can stop running services _via_:

```
$ make stop
```

If for any reason, you need to drop databases and start with fresh ones, use the
`down` target:

```
$ make down
```

## License

The code in this repository is licensed under the AGPL-3.0 unless otherwise
noted (see [LICENSE](./LICENSE) for details).
