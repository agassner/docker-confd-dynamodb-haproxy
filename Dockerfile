FROM haproxy:1.6

RUN apt-get update && \
		apt-get install -y ca-certificates

COPY files/confd-0.11.0-linux-amd64 /usr/local/bin/confd
RUN chmod a+x /usr/local/bin/confd

COPY files/confd/ /etc/confd/

ENTRYPOINT ["confd"]