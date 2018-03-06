FROM ubuntu:16.04
LABEL maintainer="Sean Cheung <theoxuanx@gmail.com>"

ARG NODE_VERSION=v9.5.0

RUN set -x \
    && apt-get update \
    && export DEBIAN_FRONTEND="noninteractive" \
    && echo "Install Dependencies..." \
    && apt-get install -y --no-install-recommends curl wget ca-certificates \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5 \
    && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends mongodb-org redis-server mysql-server mysql-client bash openssl supervisor nginx python make g++ \
	&& mkdir -p /tmp \
	&& wget -O /tmp/node.tar.gz https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.gz \
	&& tar -zxvf /tmp/node.tar.gz -C /tmp \
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