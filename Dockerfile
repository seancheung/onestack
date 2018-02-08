FROM seancheung/onestack:original
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
    && npm -g i mongo-express redis-commander \
    && echo "Clean Up..." \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*

COPY supervisord.conf /etc/
COPY entrypoint.sh /entrypoint.sh
COPY kibana.conf /etc/nginx/sites-enabled/
COPY phpmyadmin.conf /etc/nginx/sites-enabled/
COPY log4js.conf /var/opt/logstash/

VOLUME ["/var/opt/mysql", "/var/opt/redis", "/var/opt/mongodb", "/var/opt/elasticsearch", "/var/opt/logstash"]
EXPOSE 3306 6379 27017 9200 9300 5601 5000 5000/udp 8080 8081 8082 8083

ENV ES_JAVA_OPTS "-Xms512m -Xmx512m"

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]