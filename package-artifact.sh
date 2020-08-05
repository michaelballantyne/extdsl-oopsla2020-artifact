#!/bin/bash

cd $(dirname $(realpath $0))

sh dependencies/download-racket.sh
git-archive-all -v --prefix 625 -C ./ --include dependencies/racket-7.8-x86_64-linux-natipkg.sh --force-submodules 625.tar.bz2
