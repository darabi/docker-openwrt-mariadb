## -*- docker-image-name: "mcreations/openwrt-mariadb" -*-

FROM mcreations/openwrt-x64

MAINTAINER Reza Rahimi <rahimi@m-creations.net>

VOLUME /data/

ADD image/root/ /

RUN mkdir -p /data/{mariadb,tmp} && \
    opkg update && \
    opkg install mariadb-server mariadb-client mariadb-client-extra && \
    sed -i "s/^bind-address.*$/bind-address = 0.0.0.0/g" /etc/mysql/my.cnf && \
    sed -i "s|/var/run/mariadb.sock|/tmp/run/mariadb.sock|g" /etc/mysql/my.cnf && \
    sed -i "s|/.*binlog_format.*|binlog_format=mixed|g" /etc/mysql/my.cnf && \
    sed -i "s/\`hostname\`/\"\$HOSTNAME\"/g" /usr/bin/mysql_install_db && \
    sed -i "s/\`hostname\`/\"\$HOSTNAME\"/g" /usr/bin/mysqld_safe && \
    mkdir -p /docker-entrypoint-initdb.d

ENTRYPOINT ["/mariadb.sh"]

EXPOSE 3306
CMD ["mysqld"]

