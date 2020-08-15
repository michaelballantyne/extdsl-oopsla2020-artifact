#!/bin/bash

cd $(dirname $(realpath $0))

function install {
  pushd $1
  raco pkg install --skip-installed --deps fail
  popd
}

install ee-lib
install dsls/cmdline-ee
install dsls/minikanren-ee
install dsls/racket-peg-ee
install dsls/racket-rash/linea
install dsls/racket-rash/shell-pipeline
install dsls/racket-rash/rash
install dsls/type-expander

raco setup --pkgs ee-lib cmdline-ee minikanren-ee racket-peg-ee linea shell-pipeline rash type-expander

for f in $(find ./examples -not -path '*/\.*' -name *.rkt)
do
  raco make $f
done
