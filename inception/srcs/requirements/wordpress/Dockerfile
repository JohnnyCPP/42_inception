ARG  ALPINE_DIGEST=sha256:fd791d74b68913cbb027c6546007b3f0d3bc45125f797758156952bc2d6daf40

FROM alpine@${ALPINE_DIGEST}

RUN apk update && apk upgrade && \
    apk add --no-cache \
    php85 \
    php85-fpm \
    php85-mysqli \
    php85-curl \
    php85-json \
    php85-phar \
    php85-openssl \
    php85-mbstring \
    php85-session \
    php85-gd \
    php85-xml \
    php85-tokenizer \
    php85-fileinfo \
    php85-zip \
    mariadb-client \
    wget \
    curl \
    gosu

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php && \
    mkdir -p /var/www/html && \
    chown -R nobody:nobody /run/php && \
    chown -R nobody:nobody /var/www/html

RUN ln -s /usr/bin/php85 /usr/bin/php

COPY conf/entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html

EXPOSE 9000/tcp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["php-fpm85", "-F"]
