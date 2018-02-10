FROM seancheung/onestack:slim
LABEL maintainer="Sean Cheung <theoxuanx@gmail.com>"

RUN set -x \
    && apt-get update \
    && echo "Install Dependencies..." \
    && apt-get install -y php7.0-fpm \
    && echo "phpmyadmin phpmyadmin/internal/skip-preseed boolean true" | debconf-set-selections \
    && echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect" | debconf-set-selections \
    && echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections \
    && apt-get install -y --no-install-recommends phpmyadmin \
    && sed -i '110s#^#$cfg["Servers"][$i]["auth_type"] = "config";\n$cfg["Servers"][$i]["username"] = "root";\n$cfg["Servers"][$i]["password"] = "";\n$cfg["Servers"][$i]["AllowNoPassword"] = TRUE;\n#' /etc/phpmyadmin/config.inc.php \
    && echo "listen=/var/run/php7.0-fpm.sock" >> /etc/php/7.0/fpm/php-fpm.conf \
	&& mkdir -p /var/run/php \
    && npm -g i mongo-express redis-commander \
    && echo "Clean Up..." \
    && rm -rf /var/lib/apt/lists/*

COPY supervisor /etc/supervisor/conf.d/
COPY phpmyadmin.conf /etc/nginx/sites-enabled/

EXPOSE 8080 8081 8082