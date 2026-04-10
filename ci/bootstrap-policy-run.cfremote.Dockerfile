ARG CFENGINE_VERSION="master"
FROM debian
RUN apt update && apt upgrade -y
RUN apt install -y pipx sudo make automake autoconf git procps python3
RUN pipx install cf-remote
