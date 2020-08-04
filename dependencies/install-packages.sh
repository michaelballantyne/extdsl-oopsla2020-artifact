#!/bin/bash

cd $(dirname $(realpath $0))

PKG_DEPS=`cat package-list.txt`
raco pkg install --skip-installed --catalog racket-packages/catalog --auto $PKG_DEPS

