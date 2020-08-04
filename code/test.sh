#!/bin/bash

cd $(dirname $(realpath $0))

raco test -p cmdline-ee minikanren-ee racket-peg-ee linea shell-pipeline rash type-expander
raco test examples
