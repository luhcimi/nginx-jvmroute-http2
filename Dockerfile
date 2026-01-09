FROM rockylinux:8
RUN dnf -y groupinstall 'Development Tools'
RUN dnf -y install wget

WORKDIR /tmp
RUN wget https://nginx.org/download/nginx-1.29.4.tar.gz
RUN tar -zxvf nginx-1.29.4.tar.gz

WORKDIR /tmp/nginx-1.29.4
RUN wget https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.47/pcre2-10.47.tar.gz
RUN wget https://github.com/openssl/openssl/releases/download/openssl-3.6.0/openssl-3.6.0.tar.gz
RUN wget http://zlib.net/zlib-1.3.1.tar.gz
RUN wget https://github.com/vision5/ngx_devel_kit/archive/refs/tags/v0.3.4.tar.gz
RUN wget https://github.com/openresty/set-misc-nginx-module/archive/refs/tags/v0.33.tar.gz
RUN wget https://github.com/openresty/echo-nginx-module/archive/refs/tags/v0.64.tar.gz
RUN wget https://github.com/vozlt/nginx-module-url/archive/master.tar.gz
RUN tar -zxvf pcre2-10.47.tar.gz
RUN tar -zxvf openssl-3.6.0
RUN tar -zxvf zlib-1.3.1.tar.gz
RUN tar -zxvf v0.3.4.tar.gz
RUN tar -zxvf v0.33.tar.gz
RUN tar -zxvf v0.64.tar.gz
RUN tar -zxvf master.tar.gz

RUN wget https://github.com/nulab/nginx-upstream-jvm-route/archive/v1.12.0.tar.gz
RUN tar -zxvf v1.12.0.tar.gz

WORKDIR /tmp/nginx-1.29.4/nginx-upstream-jvm-route-1.12.0
RUN rm -f ngx_http_upstream_jvm_route_module.c
RUN rm -f jvm_route.patch
RUN wget https://github.com/nulab/nginx-upstream-jvm-route/raw/master/ngx_http_upstream_jvm_route_module.c

WORKDIR /tmp/nginx-1.29.4
RUN wget https://github.com/nulab/nginx-upstream-jvm-route/raw/master/jvm_route.patch
RUN patch -t -p0 < ./jvm_route.patch 

RUN ./configure --with-http_ssl_module --with-http_v2_module --with-http_realip_module \
   --add-module=./nginx-upstream-jvm-route-1.12.0/ --with-zlib=./zlib-1.3.1 \
   --with-pcre=./pcre2-10.47 --with-openssl=./openssl-3.6.0 --prefix=/usr/local/nginx \
   --with-debug --add-module=./ngx_devel_kit-0.3.4/ \
   --add-module=./set-misc-nginx-module-0.33/ \
   --add-module=./echo-nginx-module-0.64/ --add-module=./nginx-module-url-master/
RUN make
RUN make install

RUN /usr/local/nginx/sbin/nginx -t

#COPY ./nginx.conf /usr/local/nginx/conf/

# Copy the SSL/TLS certificate files:
RUN mkdir /usr/local/nginx/ssl
#COPY ./nginx.key /usr/local/nginx/ssl/
#COPY ./nginx.crt /usr/local/nginx/ssl/

RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log
RUN ln -sf /dev/stderr /usr/local/nginx/logs/error.log

EXPOSE 80 443

# Based on an explanation found at https://stackoverflow.com/a/26735742
ENTRYPOINT ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
