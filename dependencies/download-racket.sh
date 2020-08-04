#!/bin/bash

cd $(dirname $(realpath $0))

if [ ! -f "racket-7.8-x86_64-linux-natipkg.sh" ]; then
  curl -L https://download.racket-lang.org/releases/7.8/installers/racket-7.8-x86_64-linux-natipkg.sh --output racket-7.8-x86_64-linux-natipkg.sh
fi
