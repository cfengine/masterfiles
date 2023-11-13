FROM alpine
RUN apk update && apk add cfengine make automake autoconf git
WORKDIR /mpf
COPY . .
RUN ./autogen.sh --prefix=/var/lib/cfengine
RUN make install
RUN which cf-agent
RUN cf-agent -IB $(hostname -i) | tee bootstrap.log
RUN cf-agent -KIf update.cf | tee update.log
RUN cf-agent -KI | tee promise.log
RUN cf-agent -KI | tee -a promise.log
RUN cf-agent -KI | tee -a promise.log
