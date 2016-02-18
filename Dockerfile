## -*- docker-image-name: "mcreations/openwrt-mariadb" -*-

FROM mcreations/openwrt-x64

MAINTAINER Reza Rahimi <rahimi@m-creations.net>

VOLUME /data/

# must be specified when starting the container
ENV PASSWORD=""

ENV DATADIR=/data/mariadb
ENV INIT_DIR=/data/dbinit

ADD image/root/ /

RUN opkg update && \
    opkg install mariadb-server mariadb-client mariadb-client-extra && \
    rm /tmp/opkg-lists/* &&\
    sed -i "s/^bind-address.*$/bind-address = 0.0.0.0/g" /etc/mysql/my.cnf && \
    sed -i "s|/var/run/mariadb.sock|/tmp/run/mariadb.sock|g" /etc/mysql/my.cnf && \
    sed -i "s|/.*binlog_format.*|binlog_format=mixed|g" /etc/mysql/my.cnf && \
    sed -i "s/\`hostname\`/\"\$HOSTNAME\"/g" /usr/bin/mysql_install_db && \
    sed -i "s/\`hostname\`/\"\$HOSTNAME\"/g" /usr/bin/mysqld_safe

ENTRYPOINT ["/mariadb.sh"]

EXPOSE 3306
CMD ["mysqld"]

