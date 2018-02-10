FROM alpine:3.6
LABEL maintainer="Sean Cheung <theoxuanx@gmail.com>"

RUN set -x \
    && echo "Install Dependencies..." \
	&& apk add --no-cache nodejs nodejs-npm mysql mysql-client redis --repository=http://dl-3.alpinelinux.org/alpine/edge/main/ \
	&& apk add --no-cache mongodb --repository=http://dl-3.alpinelinux.org/alpine/edge/community/ \
	&& apk add --update --no-cache php5-fpm \
	&& apk add --update --no-cache bash openssl supervisor su-exec nginx python make g++ phpmyadmin \
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
    chown nginx:nginx "$path"; \
	done \
	&& mkdir -p /var/run/php \
	&& mkdir -p /etc/supervisor/conf.d \
	&& echo "listen=/var/run/php5-fpm.sock" >> /etc/php5/php-fpm.conf \
	&& echo "listen.owner=nginx" >> /etc/php5/php-fpm.conf \
	&& echo "listen.group=nginx" >> /etc/php5/php-fpm.conf \
	&& echo "listen.mode=0660" >> /etc/php5/php-fpm.conf \
	&& rm /etc/nginx/conf.d/default.conf \
	&& npm -g i mongo-express redis-commander

COPY supervisord.conf /etc/
COPY supervisor /etc/supervisor/conf.d/
COPY config.inc.php /etc/phpmyadmin/config.inc.php
COPY phpmyadmin.conf /etc/nginx/conf.d/
COPY entrypoint.sh /entrypoint.sh

VOLUME ["/var/opt/mysql", "/var/opt/redis", "/var/opt/mongodb", "/etc/supervisor/conf.d", "/etc/nginx/conf.d"]
EXPOSE 3306 6379 27017 8080 8081 8082

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]