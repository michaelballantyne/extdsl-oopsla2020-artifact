# Getting started

Our artifact is packaged as sources together with a Dockerfile that
creates an appropriate execution environment. The following commands
will unzip the artifact, build a docker image with needed dependencies,
and launch a container. Note that depending on your Docker configuration
you may need to run the docker commands as root. We tested these
instructions with Docker Desktop 2.3.0.3 on Mac OS 10.14.  The only
dependencies beyond those included in the artifact archive are Docker
and the Ubuntu 20.04 base Docker image that is downloaded when building
our artifact's image.

```
tar -xvjf 625.tar.bz2
cd 625
docker build -t artifact625 ./
docker create -ti --name artifact625 --network none --mount "type=bind,src=${PWD}/code,dst=/root/code" artifact625
docker start artifact625
```

Once the container is running, this command builds our library,
case studies, and examples:

```
docker exec artifact625 /root/code/build.sh
```

Finally, this command runs all tests and examples:

```
docker exec artifact625 /root/code/test.sh
```

# Step by step

Our paper makes no experimental claims. Therefore, our artifact simply
demonstrates that our new syntax system API and DSL expander case
studies work in the way illustrated by the examples in the paper.
The remainder of this overview shows how the code excerpts in the paper
correspond to our implementations and complete examples. It also shows
how to modify the PEG DSL with a new element of syntactic sugar and a
new core form.

## Guide to the code

The `dependencies` directory includes a linux Racket installer and
snapshots of the Racket packages that our case studies depend on. The
`Dockerfile` uses these files to build an image.

The `code` directory contains all the code developed along with our
paper:

* `ee-lib` is the library that implements our new syntax system API.
* `dsls` contains the implementations of our case study DSLs. Each DSL
  has a DEVELOPING.md file that describes its code.
    * Parsing Expression Grammars: `racket-peg-ee`
    * Command-line argument parsing: `cmdline-ee`
    * miniKanren logic programming language: `minikanren-ee`
    * Rash shell language: `racket-rash`
    * Typed Racket's language of types: `type-expander`
* `examples` contains code for each example in the paper.

The `code` directory is shared between your machine and the Docker
container, where it is mounted at `/root/code`.  Thus you can edit the
examples or DSL implementations on your host machine and run the code in
the container. To get a shell in the container, run:

```
docker exec -ti artifact625 /bin/bash
```

In general, you can run a `.rkt` file with the command:

```
racket <filename>
```

and run any tests embedded in the file with:

```
raco test <filename>
```

If you modify a dependency of a file, you may need to re-build the compiled
version of the file for the changes to take effect. Use the command:

```
raco make <filename>
```

## Code exerpts



## Adding your own macro

## Adding a core language feature

## Tear down

The following commands delete the docker container and image:

```
docker container stop artifact625
docker container rm artifact625
docker image rm artifact625
```

If you would like to remove the base Ubuntu 20.04 image as well, run:

```
docker image rm ubuntu:20.04
```
