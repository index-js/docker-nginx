FROM dotcloudid/alpine:latest-stable

LABEL maintainer="Yanglin <i@yangl.in>"
LABEL from="https://github.com/nginxinc/docker-nginx/tree/master/mainline/alpine"
LABEL reference="https://docs.docker.com/develop/develop-images/dockerfile_best-practices"


# Mainline-1.15.6, Stable-1.14.1
ENV VERSION   1.15.6
ENV TIMEZONE  Asia/Shanghai
ENV PREFIX    /etc/nginx

RUN NGINX_SBIN="/usr/sbin/nginx" \
    && CONFIG="\
        --prefix=$PREFIX \
        --sbin-path=$NGINX_SBIN \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_v2_module \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-mail \
        --with-mail_ssl_module \
    " \
    && addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        linux-headers \
        curl \
        grep \
        sed \
    && curl -fSL https://nginx.org/download/nginx-$VERSION.tar.gz -o nginx.tar.gz \
    && mkdir -p /usr/src \
    && tar -zxC /usr/src -f nginx.tar.gz \
    && rm nginx.tar.gz \
    && cd /usr/src/nginx-$VERSION \
    \
    # Remove "Server: nginx"
    && grep -rl ".server == NULL" ./src/http | xargs sed -i "s/r->headers_out\.server == NULL/0/g" \
    && grep -rl "<hr><center>" ./src/http | xargs sed -i "s/<hr><center>.*$/<hr><center>Server Error Page<\/center>\" CRLF/g" \
    \
    # Compile
    && ./configure $CONFIG \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && strip $NGINX_SBIN* \
    && rm -rf /usr/src/nginx-$VERSION \
    && mkdir -p $PREFIX/conf.d \
    \
    # Bring in gettext so we can get `envsubst`, then throw the rest away.
    # To do this, we need to install `gettext` then move `envsubst` out of the way so `gettext` can be deleted completely, then move `envsubst` back.
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' $NGINX_SBIN $PREFIX/modules/*.so /tmp/envsubst \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --no-cache --virtual .nginx-rundeps $runDeps \
    && apk del .build-deps \
    && apk del .gettext \
    && rm -rf /var/cache/apk/* \
    && mv /tmp/envsubst /usr/local/bin/ \
    && nginx -V \
    \
    # Nginx Crontab
    && echo "# Cut Nginx Logs" >> /etc/crontabs/root \
    && echo "0       0       *       *       *       /bin/sh   /etc/nginx/cut-nginx-logs.sh" >> /etc/crontabs/root \
    && echo >> /etc/crontabs/root \
    && crontab -l


COPY nginx.conf $PREFIX/conf/nginx.conf
COPY default.conf $PREFIX/conf.d/default.conf

COPY cut-nginx-logs.sh $PREFIX/cut-nginx-logs.sh

EXPOSE 80 443
STOPSIGNAL SIGTERM

CMD ["/bin/sh", "-c", "nginx && crond -f"]
