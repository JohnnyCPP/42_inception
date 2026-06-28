ARG  ALPINE_DIGEST=sha256:fd791d74b68913cbb027c6546007b3f0d3bc45125f797758156952bc2d6daf40

FROM alpine@${ALPINE_DIGEST}

RUN apk update && apk upgrade && \
    apk add --no-cache \
    mariadb \
    mariadb-client \
    mariadb-common \
    mariadb-server-utils \
    gosu

RUN mkdir -p /var/lib/mysql && \
    mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 755 /var/run/mysqld

COPY conf/entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306/tcp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["mariadbd", "--datadir=/var/lib/mysql", "--skip-networking"]

LABEL "fr.42.jonnavar.vendor"="ACME Incorporated"
