# kimmobrunfeldt/planter

This Dockerfile packages [planter](https://github.com/achiku/planter) and [plantuml](https://github.com/plantuml/plantuml) into a Docker image. They are both needed to get Postgres ER diagrams as images.

Create an ER diagram out of Postgres database from `public` schema, from tables matching `table_name LIKE '%user%'`:

```
docker run -v $PWD:/root -w /root --rm -it kimmobrunfeldt/planter er postgres://planter@localhost/planter?sslmode=disable public "%user%"
```

or create an ER diagram of all tables with the original CLI tools:

```
docker run -v $PWD:/root -w /root --rm -it kimmobrunfeldt/planter planter postgres://planter@localhost/planter?sslmode=disable -o example.uml
docker run -v $PWD:/root -w /root --rm -it kimmobrunfeldt/planter plantuml -verbose example.uml
```

In Fedora, if you're using podman, you need to add option `--security-opt label=disable` to disable SELinux security isolation which prevents volume mounting. See https://github.com/containers/libpod/issues/3683 for more.


## Common pitfalls

**The created diagram is empty!**

Make sure the postgres schema is correct. The default is `public`.

## How to use

```
docker run -v $PWD:/root -w /root --rm -it kimmobrunfeldt/planter <command> <args>
```

The Docker file exposes these commands:

* `planter <args>` Which would be same as running `planter <args` *(surprise)*. Arguments are directly passed to planter.
* `plantuml <args>` Which would be same as running `java -jar plantuml.jar <args>`.
* `er <postgres-url> [postgres-schema] [tables-name-pattern]` Which is a convenience command for combining commands and directly getting the image.


## Update to latest version

```
docker pull kimmobrunfeldt/planter:latest
```


## Building with podman

```
podman build --cgroup-manager=cgroupfs .
```

Without the extra flag, building fails to:

```
STEP 1: FROM ubuntu:18.04
STEP 2: RUN apt-get -q -y update
ERRO[0000] systemd cgroup flag passed, but systemd support for managing cgroups is not available
systemd cgroup flag passed, but systemd support for managing cgroups is not available
error running container: error creating container for [/bin/sh -c apt-get -q -y update]: : exit status 1
Error: error building at STEP "RUN apt-get -q -y update": error while running runtime: exit status 1
```

More at https://github.com/opencontainers/runc/issues/2163.
