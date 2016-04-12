FROM haproxy:1.6

ENV CONFD_VERSION 0.11.0

RUN apt-get update && \
		apt-get install -y ca-certificates

ADD https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 /usr/local/bin/confd
RUN chmod a+x /usr/local/bin/confd

COPY files/confd/ /etc/confd/

ENTRYPOINT ["confd"]