ARG  ALPINE_DIGEST=sha256:fd791d74b68913cbb027c6546007b3f0d3bc45125f797758156952bc2d6daf40

FROM alpine@${ALPINE_DIGEST}

RUN apk update && apk upgrade && \
    apk add --no-cache \
    nginx \
    openssl \
    curl

RUN mkdir -p /etc/nginx/ssl && \
    mkdir -p /var/www/html

RUN openssl req -x509 -noenc -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/L=Paris/O=42/CN=jonnavar.42.fr"

COPY conf/nginx.conf /etc/nginx/http.d/default.conf

RUN chown -R nginx:nginx /var/www/html && \
    chown -R nginx:nginx /etc/nginx/ssl && \
    chmod 600 /etc/nginx/ssl/nginx.key && \
    chmod 644 /etc/nginx/ssl/nginx.crt

EXPOSE 443/tcp

CMD ["nginx", "-g", "daemon off;"]
