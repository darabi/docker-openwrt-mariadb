#!/bin/bash
set -e

function shut_down() {
		echo "Shutting down"
		kill -TERM $pid 2>/dev/null
}

trap "shut_down" SIGKILL SIGTERM SIGHUP SIGINT EXIT


# TODO: remove this backward compatibility hack, as we renamed the env
# var from MYSQL_ROOT_PASSWORD to PASSWORD
if [[ -z "$PASSWORD" && ! -z "$MYSQL_ROOT_PASSWORD" ]] ; then
		printf "\n\nPlease use PASSWORD instead of MYSQL_ROOT_PASSWORD!!!!\n\n"
		PASSWORD=$MYSQL_ROOT_PASSWORD
fi

# if command starts with an option, prepend mysqld
if [ "${1:0:1}" = '-' ]; then
	set -- mysqld "$@"
fi

if [ "$1" = 'mysqld' ]; then

	if [ ! -d "$DATADIR/mysql" ]; then
		if [ -z "$PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" ]; then
			echo >&2 'error: database is uninitialized and PASSWORD not set'
			echo >&2 '  Did you forget to add -e PASSWORD=... ?'
			exit 1
		fi

		chown -R root:root "$DATADIR"

		echo 'Initializing database'
		mysql_install_db --force --basedir=/usr
		echo 'Database initialized'

		mysqld --user=mysql --datadir="$DATADIR" --skip-networking &
		pid="$!"

		mysql=( mysql --protocol=socket -uroot )

		for i in {30..0}; do
			if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
				break
			fi
			echo 'MariaDB init process in progress...'
			sleep 1
		done
		if [ "$i" = 0 ]; then
			echo >&2 'MariaDB init process failed.'
			exit 1
		fi

		/usr/bin/mysql_upgrade

		mysql_tzinfo_to_sql /usr/share/zoneinfo | "${mysql[@]}" mysql

		"${mysql[@]}" <<-EOSQL
			-- What's done in this file shouldn't be replicated
			--  or products like mysql-fabric won't work
			SET @@SESSION.SQL_LOG_BIN=0;
			DELETE FROM mysql.user ;
			CREATE USER 'root'@'%' IDENTIFIED BY '${PASSWORD}' ;
			GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
			DROP DATABASE IF EXISTS test ;
			FLUSH PRIVILEGES ;
		EOSQL
		if [ ! -z "$PASSWORD" ]; then
			mysql+=( -p"${PASSWORD}" )
		fi

		if [ "$MYSQL_DATABASE" ]; then
			echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" | "${mysql[@]}"
			mysql+=( "$MYSQL_DATABASE" )
		fi

		if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
			echo "CREATE USER '"$MYSQL_USER"'@'%' IDENTIFIED BY '"$MYSQL_PASSWORD"' ;" | "${mysql[@]}"

			if [ "$MYSQL_DATABASE" ]; then
				echo "GRANT ALL ON \`"$MYSQL_DATABASE"\`.* TO '"$MYSQL_USER"'@'%' ;" | "${mysql[@]}"
			fi

			echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"
		fi

		echo
		for f in $INIT_DIR/*; do
			case "$f" in
				*.sh)  echo "$0: running $f"; "$f" && printf "\n=== Successfully  executed $f\n" && mv "$f" $INIT_DIR/imported || printf "\n=== Error while executing $f\n" ;;
				*.sql) echo "$0: running $f"; "${mysql[@]}" < "$f" && printf "\n=== Successfully imported $f\n" && mv "$f" $INIT_DIR/imported || printf "\n=== Error while importing $f\n"  ;;
				imported) ;;
				*)     echo "$0: ignoring $f" ;;
			esac
			echo
		done

		if ! kill -s TERM "$pid" || ! wait "$pid"; then
			echo >&2 'MariaDB init process failed.'
			exit 1
		fi

		echo
		echo 'MariaDB init process done. Ready for start up.'
		echo
	fi

fi

exec "$@" &
pid=$!

wait

# Local Variables:
# mode: shell-script
# indent-tabs-mode: t
# tab-width: 2
# End:
