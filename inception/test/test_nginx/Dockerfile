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
    nginx \
    openssl \
    net-tools \
    procps

RUN ssh-keygen -A && \
    echo "root:jonnavar" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

RUN adduser -D -h /home/jonnavar -s /bin/bash jonnavar && \
    echo "jonnavar:jonnavar" | chpasswd && \
    echo "jonnavar ALL=(ALL) ALL" >> /etc/sudoers

RUN mkdir -p /etc/nginx/ssl && \
    mkdir -p /var/www/html && \
    openssl req -x509 -noenc -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/C=FR/L=Paris/O=42/CN=jonnavar.42.fr" && \
    echo "<h1>NGINX Test Page</h1>" > /var/www/html/index.html && \
    cat > /etc/nginx/http.d/default.conf << 'EOF'
server {
    listen 443 ssl;
    server_name jonnavar.42.fr;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    root /var/www/html;
    index index.html index.php;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

EXPOSE 443/tcp

EXPOSE 22/tcp

CMD ["/usr/sbin/sshd", "-D"]
