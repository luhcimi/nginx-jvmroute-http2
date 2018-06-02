FROM centos:7
RUN yum -y groupinstall 'Development Tools'
RUN yum -y install wget

WORKDIR /tmp
RUN wget https://nginx.org/download/nginx-1.12.2.tar.gz
RUN tar -zxvf nginx-1.12.2.tar.gz

WORKDIR /tmp/nginx-1.12.2
RUN wget https://ftp.pcre.org/pub/pcre/pcre-8.41.tar.gz
RUN wget https://www.openssl.org/source/openssl-1.0.2o.tar.gz
RUN wget http://zlib.net/zlib-1.2.11.tar.gz
RUN wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.1rc1.tar.gz
RUN wget https://github.com/openresty/set-misc-nginx-module/archive/v0.32rc1.tar.gz
RUN wget https://github.com/openresty/echo-nginx-module/archive/v0.61.tar.gz
RUN wget https://github.com/vozlt/nginx-module-url/archive/master.tar.gz
RUN tar -zxvf pcre-8.41.tar.gz
RUN tar -zxvf openssl-1.0.2o.tar.gz
RUN tar -zxvf zlib-1.2.11.tar.gz
RUN tar -zxvf v0.3.1rc1.tar.gz
RUN tar -zxvf v0.32rc1.tar.gz
RUN tar -zxvf v0.61.tar.gz
RUN tar -zxvf master.tar.gz

RUN wget https://github.com/nulab/nginx-upstream-jvm-route/archive/1.6.tar.gz
RUN tar -zxvf 1.6.tar.gz

WORKDIR /tmp/nginx-1.12.2/nginx-upstream-jvm-route-1.6
RUN rm -f ngx_http_upstream_jvm_route_module.c
RUN rm -f jvm_route.patch
RUN wget https://github.com/nulab/nginx-upstream-jvm-route/raw/master/ngx_http_upstream_jvm_route_module.c

WORKDIR /tmp/nginx-1.12.2
RUN wget https://github.com/nulab/nginx-upstream-jvm-route/raw/master/jvm_route.patch
RUN patch -t -p0 < ./jvm_route.patch 

RUN ./configure --with-http_ssl_module --with-http_v2_module --with-http_realip_module \
   --add-module=./nginx-upstream-jvm-route-1.6/ --with-zlib=./zlib-1.2.11 \
   --with-pcre=./pcre-8.41 --with-openssl=./openssl-1.0.2o --prefix=/usr/local/nginx \
   --with-debug --add-module=./ngx_devel_kit-0.3.1rc1/ \
   --add-module=./set-misc-nginx-module-0.32rc1/ \
   --add-module=./echo-nginx-module-0.61/ --add-module=./nginx-module-url-master/
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