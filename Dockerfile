FROM ubuntu:20.04
RUN apt-get update -y
RUN apt-get install ca-certificates tzdata make libedit2 -y
COPY dependencies /root/dependencies
COPY README.md /root/README.md
RUN sh /root/dependencies/racket-7.8-x86_64-linux-natipkg.sh --unix-style --dest /usr/
RUN sh /root/dependencies/install-packages.sh

ENTRYPOINT ["/bin/bash"]

