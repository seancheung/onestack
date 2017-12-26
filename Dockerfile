FROM ubuntu:16.04
LABEL maintainer="Sean Cheung <theoxuanx@gmail.com>"

ARG CN_MIRROR
ARG ELK_VERSION=6.1.1

RUN if [ -n "$CN_MIRROR" ]; then mv /etc/apt/sources.list /etc/apt/sources.list.bak \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list; \
    fi

RUN mkdir -p /tmp \
    && cd /tmp \
    && set -x \
    && apt-get update \
    && export DEBIAN_FRONTEND="noninteractive" \
    && echo "Install Dependencies..." \
    && apt-get install -y --no-install-recommends curl wget ca-certificates \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5 \
    && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends mongodb-org redis-server nodejs mysql-server mysql-client openjdk-8-jre bash git openssl supervisor nginx apache2-utils python make g++ \
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
    && echo "Clean Up..." \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*

ENV PATH /usr/share/elasticsearch/bin:$PATH
ENV PATH /usr/share/logstash/bin:$PATH
ENV PATH /usr/share/kibana/bin:$PATH