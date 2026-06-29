ARG  ALPINE_DIGEST=sha256:fd791d74b68913cbb027c6546007b3f0d3bc45125f797758156952bc2d6daf40

FROM alpine@${ALPINE_DIGEST}

RUN apk update && apk upgrade && \
    apk add --no-cache \
    mariadb \
    mariadb-client \
    mariadb-common \
    mariadb-server-utils \
    openssh-server \
    openssh \
    bash \
    vim \
    curl \
    wget \
    sudo

RUN ssh-keygen -A && \
    echo "root:jonnavar" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

RUN adduser -D -h /home/jonnavar -s /bin/bash jonnavar && \
    echo "jonnavar:jonnavar" | chpasswd && \
    echo "jonnavar ALL=(ALL) ALL" >> /etc/sudoers

RUN mkdir -p /var/lib/mysql && \
    mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 755 /var/run/mysqld

EXPOSE 3306/tcp

EXPOSE 22/tcp

CMD ["/usr/sbin/sshd", "-D"]
