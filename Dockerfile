FROM alpine

LABEL maintainer="Yanglin <i@yangl.in>"
LABEL from="https://github.com/nginxinc/docker-nginx/tree/master/mainline/alpine"
LABEL reference="https://docs.docker.com/develop/develop-images/dockerfile_best-practices"

# Mainline
ENV NGINX_VERSION 1.15.5
# Stable
#ENV NGINX_VERSION 1.14.0

RUN NGINX_MENU="/etc/nginx" \
    && NGINX_SBIN="/usr/sbin/nginx" \
    && CONFIG="\
        --prefix=$NGINX_MENU \
        --sbin-path=$NGINX_SBIN \
        --user=nginx \
        --group=nginx \
        --with-http_ssl_module \
        --with-http_v2_module \
    " \
    && addgroup -S nginx \
    && adduser -D -S -s /sbin/nologin -G nginx nginx \
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
    && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
    && mkdir -p /usr/src \
    && tar -zxC /usr/src -f nginx.tar.gz \
    && rm nginx.tar.gz \
    && cd /usr/src/nginx-$NGINX_VERSION \
    \
    # Remove "Server: nginx"
    && grep -rl '.server == NULL' ./src/http | xargs sed -i 's/r->headers_out\.server == NULL/0/g' \
    && grep -rl '<hr><center>' ./src/http | xargs sed -i 's/<hr><center>.*$/<hr><center>Server Error Page<\/center>\" CRLF/g' \
    \
    # Compile
    && ./configure $CONFIG \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && strip $NGINX_SBIN* \
    && rm -rf /usr/src/nginx-$NGINX_VERSION \
    \
    # Bring in gettext so we can get `envsubst`, then throw the rest away.
    # To do this, we need to install `gettext` then move `envsubst` out of the way so `gettext` can be deleted completely, then move `envsubst` back.
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    \
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' $NGINX_SBIN $NGINX_MENU/modules/*.so /tmp/envsubst \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --no-cache --virtual .nginx-rundeps $runDeps \
    && apk del .build-deps \
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin/ \
    \
    # Bring in tzdata so users could set the timezones through the environment variables
    && apk add --no-cache tzdata \
    && nginx -V

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
