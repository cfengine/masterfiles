ARG CFENGINE_VERSION="master"
FROM debian
COPY core /core
RUN apt update && apt upgrade -y
# need python3 for apt_get package module to avoid errors
RUN apt install -y sudo make automake autoconf git python3 procps
