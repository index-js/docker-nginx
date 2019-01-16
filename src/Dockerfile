FROM dotcloudid/alpine:latest-stable

LABEL maintainer="Yanglin <i@yangl.in>"
LABEL from="https://github.com/nginxinc/docker-nginx/tree/master/mainline/alpine"
LABEL reference="https://docs.docker.com/develop/develop-images/dockerfile_best-practices"


# Mainline-1.15.6, Stable-1.14.1
ENV VERSION   1.15.6
ENV PREFIX    /etc/nginx

RUN NGINX_SBIN="/usr/sbin/nginx" \
    && CONFIG="\
        --prefix=$PREFIX \
        --sbin-path=$NGINX_SBIN \
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
    && apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        linux-headers \
        make \
        curl \
        grep \
        sed \
    && curl -fSL https://nginx.org/download/nginx-$VERSION.tar.gz -o nginx.tar.gz \
    && tar -zxC /tmp -f nginx.tar.gz \
    && rm nginx.tar.gz \
    && cd /tmp/nginx-$VERSION \
    \
    # Remove "Server: nginx"
    && grep -rl ".server == NULL" ./src/http | xargs sed -i "s/r->headers_out\.server == NULL/0/g" \
    && grep -rl "<hr><center>" ./src/http | xargs sed -i "s/\(<hr><center>\).*\(<\/center>\)/\1 Server Error Page \2/g" \
    \
    # Compile
    && ./configure $CONFIG \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && strip $NGINX_SBIN* \
    && rm -rf /tmp/nginx-$VERSION \
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
    && echo "0       0       *       *       *       /bin/sh   /cut_logs.sh" >> /etc/crontabs/root \
    && echo >> /etc/crontabs/root \
    && crontab -l


COPY nginx.conf   $PREFIX/conf/nginx.conf
COPY default.conf $PREFIX/conf.d/
COPY cut_logs.sh  /

EXPOSE 80 443
STOPSIGNAL SIGTERM

CMD ["/bin/sh", "-c", "nginx && crond -f"]
