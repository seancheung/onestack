#!/bin/bash
set -e

MYSQL_INITSQL=/var/run/mysqld/.init

function boot_mysql()
{
    bootfile=$1
    cat > $bootfile << EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';
EOF

    if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
        echo "[Mysql] updating root password"
        echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;" >> $bootfile
    fi

    # MYSQL_USER: "username:password" or "username". password will be the same as username if omitted.
    # For multiple user creation, seperate them with ";".
    if [ -n "$MYSQL_USER" ]; then
        IFS=';'; users=($MYSQL_USER); unset IFS;
        for entry in "${users[@]}"; do
            IFS=':'; sub=($entry); unset IFS;
            if [ ${#sub[@]} -eq 1 ]; then
                username=${sub[0]}
                password=$username
            elif [ ${#sub[@]} -eq 2 ]; then
                username=${sub[0]}
                password=${sub[1]}
            else
                echo "[Mysql] invalid username in ${MYSQL_USER}"
                exit 1
            fi
            echo "[Mysql] create user ${username}"
            echo "CREATE USER IF NOT EXISTS '${username}'@'%' IDENTIFIED BY '${password}';" >> $bootfile
        done
    fi

    # MYSQL_DATABASE: "username@database" or "database". username will be the same as database if omitted.
    # User will be created(with password the same as username) if not exist.
    # For multiple database creation, seperate them with ";".
    if [ -n "$MYSQL_DATABASE" ]; then
        IFS=';'; ary=($MYSQL_DATABASE); unset IFS;
        for entry in "${ary[@]}"; do
            IFS='@'; sub=($entry); unset IFS;
            if [ ${#sub[@]} -eq 1 ]; then
                username=${sub[0]}
                database=$username
            elif [ ${#sub[@]} -eq 2 ]; then
                username=${sub[0]}
                database=${sub[1]}
            else
                echo "[Mysql] invalid database in ${MYSQL_DATABASE}"
                exit 1
            fi
            echo "[Mysql] create database ${database}"
            echo "CREATE DATABASE IF NOT EXISTS \`${database}\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $bootfile
            # ensure user exists
            echo "CREATE USER IF NOT EXISTS '${username}'@'%' IDENTIFIED BY '${username}';" >> $bootfile
            echo "[Mysql] grant privileges to ${username} on ${database}"
            echo "GRANT ALL PRIVILEGES ON \`${database}\`.* to '${username}'@'%';" >> $bootfile
        done
    fi

    echo "FLUSH PRIVILEGES;" >> $bootfile

    echo "[Mysql] initializing database"
    mysqld --initialize --user=mysql --datadir=/var/opt/mysql --character-set-server=utf8 --log-error=/var/log/mysql/mysqld.log
}

if [ ! -f "$MYSQL_INITSQL" ]; then
    if [ -z "$MYSQL_SKIP_INIT" ]; then
        boot_mysql "$MYSQL_INITSQL"
    else
        touch "$MYSQL_INITSQL"
    fi
fi

exec "$@"
