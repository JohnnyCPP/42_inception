ARG  ALPINE_DIGEST=sha256:fd791d74b68913cbb027c6546007b3f0d3bc45125f797758156952bc2d6daf40

FROM alpine@${ALPINE_DIGEST}

RUN apk update && apk upgrade && \
    apk add --no-cache \
    openssh-server \
    openssh \
    bash \
    vim \
    curl \
    wget \
    sudo \
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
    mariadb \
    mariadb-client \
    mariadb-common \
    mariadb-server-utils \
    net-tools \
    procps \
    gosu

RUN ssh-keygen -A && \
    echo "root:jonnavar" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

RUN adduser -D -h /home/jonnavar -s /bin/bash jonnavar && \
    echo "jonnavar:jonnavar" | chpasswd && \
    echo "jonnavar ALL=(ALL) ALL" >> /etc/sudoers

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

COPY test_script/test-db.php /var/www/html/

COPY test_script/test-db-html.php /var/www/html/

WORKDIR /var/www/html

EXPOSE 9000/tcp

EXPOSE 22/tcp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["php-fpm85", "-F"]
