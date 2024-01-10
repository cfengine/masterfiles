FROM alpine
RUN apk update && apk add cfengine make automake autoconf git
