FROM seancheung/onestack:original
LABEL maintainer="Sean Cheung <theoxuanx@gmail.com>"

RUN set -x \
    && apt-get update \
    && echo "Install Dependencies..." \
    && debconf-set-selections <<< "phpmyadmin phpmyadmin/internal/skip-preseed boolean true" \
    && debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect" \
    && debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean false" \
    && apt-get install -y --no-install-recommends phpmyadmin \
    && echo "Listen 8080" > /etc/apache2/ports.conf \
    && echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf \
    && sed -i '2s#^#RedirectMatch ^/$ /phpmyadmin\n#' /etc/phpmyadmin/apache.conf \
    && rm /etc/apache2/sites-enabled/000-default.conf \
    && rm /var/www/html/index.html \
    && npm -g i mongo-express redis-commander \
    && echo "Clean Up..." \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*

COPY supervisord.conf /etc/
COPY entrypoint.sh /entrypoint.sh
COPY kibana.conf /etc/nginx/sites-enabled/
COPY log4js.conf /var/opt/logstash/

VOLUME ["/var/opt/mysql", "/var/opt/redis", "/var/opt/mongodb", "/var/opt/elasticsearch", "/var/opt/logstash"]
EXPOSE 3306 6379 27017 9200 9300 5601 5000 5000/udp

ENV ES_JAVA_OPTS "-Xms512m -Xmx512m"

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]