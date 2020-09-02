# kimmobrunfeldt/planter

This Dockerfile packages [planter](https://github.com/achiku/planter) and [plantuml](https://github.com/plantuml/plantuml) into a Docker image. They are both needed to get Postgres ER diagrams as images.

Create an ER diagram out of Postgres database:

```
docker run -v $PWD:/root -w /root --rm -it kimmobrunfeldt/planter planter postgres://planter@localhost/planter?sslmode=disable -o example.uml
docker run -v $PWD:/root -w /root --rm -it kimmobrunfeldt/planter plantuml -verbose example.uml
```

In Fedora, if you're using podman, you need to add option `--security-opt label=disable` to disable SELinux security isolation which prevents volume mounting. See https://github.com/containers/libpod/issues/3683 for more.


## How to use

```
docker run -v $PWD:/root -w /root --rm -it kimmobrunfeldt/planter <command> <args>
```

The Docker file exposes these commands:

* `planter <args>` Which would be same as running `planter <args` *(surprise)*. Arguments are directly passed to planter.
* `plantuml <args>` Which would be same as running `java -jar plantuml.jar <args>`.

## Update to latest version

```
docker pull kimmobrunfeldt/planter:latest
```
