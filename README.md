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

## Extending the image

You can extend the image to import a DB dump as initial content of the
database. The startup script contains a mechanism for importing sql
scripts and executing shell scripts. You just have to follow some simple rules:

- the directory to add files to is `/data/dbinit`

- add your uncompressed sql scripts with extension `.sql`

- you can compress large files with bzip2 (file extension `.sql.bz2`),
  or gzip (file extension `.sql.gz`)

- add your shell scripts with extension .sh (or `.sh.bz2`, or `.sh.gz`)

- the shell scripts are executed, not 'sourced', so you have to use
  `exit errno` to indicate an error

- in case of successful execution/import, the file is compressed and
  moved to `/data/dbinit/imported`

- in case of errors, the file remains in `/data/dbinit`

The simplest repository layout for extending the image is thus:

```
.
├── Dockerfile
└── dbinit
    ├── 000-first-shell-script.sh
    ├── 001-dump-from-last-friday.sql.bz2
    └── 002-second-longish-shell-script.sh.gz
```

where the Dockerfile contains:

```
FROM mcreations/openwrt-mariadb

ADD dbinit/ /data/dbinit
```

Now you can build and enjoy:

```
docker build -t myname/my-db .

docker run --name db -d -e PASSWORD=tiger myname/my-db 

docker exec -it db mysql -uroot -ptiger
```

# Github Repo

https://github.com/m-creations/docker-openwrt-mariadb/
