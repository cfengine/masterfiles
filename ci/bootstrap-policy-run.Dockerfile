FROM alpine
RUN apk add bash
COPY core /core
COPY masterfiles /masterfiles
RUN ls /
RUN find / -name core
RUN /core/ci/install.sh
