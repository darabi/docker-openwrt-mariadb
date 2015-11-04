docker-openwrt-mariadb
======================
A docker container for running  MariaDB server which extends OpenWrt x86_64

To run you need to create a folder for storing data:
```
mkdir /mariadb-data
```
MySQL root password should pass to Docker with -e switch:
```
-e MYSQL_ROOT_PASSWORD=root
```
Example run command:
```
docker run --name <mariadb> -p 3306:3306 -v /mariadb-data:/data -e MYSQL_ROOT_PASSWORD=root --rm -it mcreations/openwrt-mariad
```
For testing that server is running:
```
mysql --protocol=TCP -uroot -proot -hlocalhost -P3306 -Bse "show databases;
```
And if the password is correct and the server is running fine you should see following result:
```
Warning: Using a password on the command line interface can be insecure.
information_schema
mysql
performance_schema
```
Github Repo
-----------
https://github.com/m-creations/docker-openwrt-mariadb/
