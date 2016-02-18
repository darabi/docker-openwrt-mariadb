# docker-openwrt-mariadb

![Docker image size](https://img.shields.io/imagelayers/image-size/mcreations/openwrt-mariadb/latest.svg)

A docker container for running [MariaDB](http://mariadb.org) server
and client which extends [OpenWrt x86_64](http://openwrt.org) for
minimal size.

## How to run

The container can be run as a MariaDB server or client.

### Run as server

The most simple way to run the container is to specify the root password with
`-e`:

```
docker run --name mariadb -e PASSWORD=root -d mcreations/openwrt-mariadb
```

The startup is currently quite verbose (for debugging purposes) and if
successful, ends with:

```
MariaDB init process done. Ready for start up.
...
[Note] mysqld (mysqld 10.x.y-MariaDB-wsrep-log) starting as process ...
...
[Note] Server socket created on IP: '0.0.0.0'.
...
[Note] mysqld: ready for connections.
Version: '10.x.y-MariaDB-wsrep-log'  socket: '/tmp/run/mariadb.sock'  port: 3306  Source distribution, wsrep_a.b.rnnnn
```

You can now run a MariaDB client inside this container:

```
docker exec -it mariadb mysql -uroot -proot
```

#### Location of data

When run as a server, the data is stored in the `/data` directory
inside the container. You can mount a volume from the host with:

```
docker run -v $HOME/data:/data -e PASSWORD=root -d mcreations/openwrt-mariadb
```

#### Exposing port 3306

If you want to connect to the MariaDB server directly from your host
or from another machine, you can expose the TCP port `3306`:

```
docker run -p 3306:3306 -e PASSWORD=root -d mcreations/openwrt-mariadb
```

and then connect to it by using the MariaDB/MySQL client which is
installed on your host:

```
mysql --protocol=TCP -u root -proot -h localhost -P 3306
```

### Run as client

You can use container linking to link to a running MariaDB container
(in this example named `mariadb`):

```
docker run --rm -it --link mariadb:db mcreations/openwrt-mariadb mysql -uroot -proot -h db
```

# Github Repo

https://github.com/m-creations/docker-openwrt-mariadb/
