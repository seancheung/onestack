FROM seancheung/onestack:original
LABEL maintainer="Sean Cheung <theoxuanx@gmail.com>"

COPY supervisord.conf /etc/
COPY entrypoint.sh /entrypoint.sh
COPY kibana.conf /etc/nginx/sites-enabled/
COPY log4js.conf /var/opt/logstash/

VOLUME ["/var/opt/mysql", "/var/opt/redis", "/var/opt/mongodb", "/var/opt/elasticsearch", "/var/opt/logstash"]
EXPOSE 3306 6379 27017 9200 9300 5601 5000 5000/udp

ENV ES_JAVA_OPTS "-Xms512m -Xmx512m"

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]