FROM seancheung/onestack:slim
LABEL maintainer="Sean Cheung <theoxuanx@gmail.com>"

ARG ELK_VERSION=6.1.1

RUN mkdir -p /tmp \
    && cd /tmp \
    && set -x \
    && echo "Install Dependencies..." \
    && apt-get update \
    && apt-get install -y --no-install-recommends openjdk-8-jre apache2-utils \
	&& echo "Download [Elasticsearch]..." \
    && wget --progress=bar:force https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELK_VERSION.deb \
    && wget --progress=bar:force https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELK_VERSION.deb.sha512 \
    && shasum -a 512 -c elasticsearch-$ELK_VERSION.deb.sha512 \
    && dpkg -i elasticsearch-$ELK_VERSION.deb \
    && echo "Download [Logstash]..." \
    && wget --progress=bar:force https://artifacts.elastic.co/downloads/logstash/logstash-$ELK_VERSION.deb \
    && wget --progress=bar:force https://artifacts.elastic.co/downloads/logstash/logstash-$ELK_VERSION.deb.sha512 \
    && shasum -a 512 -c logstash-$ELK_VERSION.deb.sha512 \
    && dpkg -i logstash-$ELK_VERSION.deb \
    && echo "Download [Kibana]..." \
    && wget --progress=bar:force https://artifacts.elastic.co/downloads/kibana/kibana-$ELK_VERSION-amd64.deb \
    && wget --progress=bar:force https://artifacts.elastic.co/downloads/kibana/kibana-$ELK_VERSION-amd64.deb.sha512 \
    && shasum -a 512 -c kibana-$ELK_VERSION-amd64.deb.sha512 \
    && dpkg -i kibana-$ELK_VERSION-amd64.deb \
    && bundled='NODE="${DIR}/node/bin/node"' \
    && custom='NODE="/usr/bin/node"' \
    && sed -i "s|$bundled|$custom|g" /usr/share/kibana/bin/kibana-plugin \
	&& sed -i "s|$bundled|$custom|g" /usr/share/kibana/bin/kibana \
    && rm -rf /usr/share/kibana/node \
    && for path in \
		/var/run/elasticsearch \
		/var/log/elasticsearch \
		/var/opt/elasticsearch \
	; do \
	mkdir -p "$path"; \
    chown elasticsearch:elasticsearch "$path"; \
	done \
    && for path in \
		/var/run/logstash \
		/var/log/logstash \
		/var/opt/logstash \
	; do \
	mkdir -p "$path"; \
    chown logstash:logstash "$path"; \
	done \
    && for path in \
		/var/run/kibana \
		/var/log/kibana \
		/var/opt/kibana \
	; do \
	mkdir -p "$path"; \
    chown kibana:kibana "$path"; \
	done \
    && echo "Clean Up..." \
	&& rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*

ENV PATH /usr/share/elasticsearch/bin:$PATH
ENV PATH /usr/share/logstash/bin:$PATH
ENV PATH /usr/share/kibana/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV ES_JAVA_OPTS "-Xms512m -Xmx512m"

COPY entrypoint.sh /entrypoint-elk.sh
COPY elk.conf /etc/supervisor/conf.d/
COPY log4js.conf /var/opt/logstash/
COPY kibana.conf /etc/nginx/sites-enabled/

VOLUME ["/var/opt/elasticsearch", "/var/opt/logstash"]
EXPOSE 80 9200 5000/udp

ENTRYPOINT ["/entrypoint-elk.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]