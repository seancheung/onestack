FROM ubuntu:16.04
LABEL maintainer="Sean Cheung <theoxuanx@gmail.com>"

ARG MONGO_VERSION=3.6.3
ARG NODE_VERSION=v9.5.0

RUN set -x \
    && apt-get update \
    && export DEBIAN_FRONTEND="noninteractive" \
    && echo "Install Dependencies..." \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl wget ca-certificates redis-server mysql-server mysql-client bash openssl supervisor nginx python make g++ \
	&& mkdir -p /tmp \
	&& echo "Downloading mongodb $MONGO_VERSION..." \
	&& wget -O /tmp/mongodb.tar.gz https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-${MONGO_VERSION}.tgz \
	&& tar -zxvf /tmp/mongodb.tar.gz -C /tmp \
	&& cp -r /tmp/mongodb-linux-x86_64-${MONGO_VERSION}/bin/* /usr/bin \
	&& groupadd -r mongodb \
	&& useradd -r -s /bin/false -g mongodb mongodb \
	&& echo "Downloading nodejs $NODE_VERSION..." \
	&& wget -O /tmp/nodejs.tar.gz https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.gz \
	&& tar -zxvf /tmp/nodejs.tar.gz -C /tmp \
	&& cp -r /tmp/node-${NODE_VERSION}-linux-x64/bin/* /usr/bin/ \
	&& cp -r /tmp/node-${NODE_VERSION}-linux-x64/include/* /usr/include/ \
	&& cp -r /tmp/node-${NODE_VERSION}-linux-x64/lib/* /usr/lib/ \
	&& cp -r /tmp/node-${NODE_VERSION}-linux-x64/share/* /usr/share/ \
    && for path in \
		/var/run/mysqld \
		/var/log/mysql \
		/var/opt/mysql \
	; do \
	mkdir -p "$path"; \
    chown mysql:mysql "$path"; \
	done \
    && for path in \
		/var/run/redis \
		/var/log/redis \
		/var/opt/redis \
	; do \
	mkdir -p "$path"; \
    chown redis:redis "$path"; \
	done \
    && for path in \
		/var/run/mongodb \
		/var/log/mongodb \
		/var/opt/mongodb \
	; do \
	mkdir -p "$path"; \
    chown mongodb:mongodb "$path"; \
	done \
    && for path in \
		/var/run/nginx \
		/var/log/nginx \
	; do \
	mkdir -p "$path"; \
    chown www-data:www-data "$path"; \
	done \
	&& rm /etc/nginx/sites-enabled/default \
    && echo "Clean Up..." \
	&& rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*

COPY supervisord.conf /etc/
COPY supervisor /etc/supervisor/conf.d/
COPY entrypoint.sh /entrypoint.sh

VOLUME ["/var/opt/mysql", "/var/opt/redis", "/var/opt/mongodb", "/etc/supervisor/conf.d", "/etc/nginx/sites-enabled"]
EXPOSE 3306 6379 27017

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]