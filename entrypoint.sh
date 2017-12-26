#!/bin/bash
set -e

MYSQL_INITSQL=/var/run/mysqld/.init

function ensure_dir()
{
    for dir in "/var/run/mysqld" "/var/log/mysql" "/var/opt/mysql"; do
        mkdir -p $dir
        chown mysql:mysql $dir
    done
    for dir in "/var/run/redis" "/var/log/redis" "/var/opt/redis"; do
        mkdir -p $dir
        chown redis:redis $dir
    done
    for dir in "/var/run/mongodb" "/var/log/mongodb" "/var/opt/mongodb"; do
        mkdir -p $dir
        chown mongodb:mongodb $dir
    done
    for dir in "/var/run/elasticsearch" "/var/log/elasticsearch" "/var/opt/elasticsearch"; do
        mkdir -p $dir
        chown elasticsearch:elasticsearch $dir
    done
    for dir in "/var/run/logstash" "/var/log/logstash" "/var/opt/logstash"; do
        mkdir -p $dir
        chown logstash:logstash $dir
    done
    for dir in "/var/run/kibana" "/var/log/kibana" "/var/opt/kibana"; do
        mkdir -p $dir
        chown kibana:kibana $dir
    done
    for dir in "/var/run/nginx" "/var/log/nginx"; do
        mkdir -p $dir
        chown www-data:www-data $dir
    done
}

function boot_mysql()
{
    bootfile=$1
    cat > $bootfile << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '';
EOF

    if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
        echo "[Mysql] updating root password"
        echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;" >> $bootfile
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

function init_nginx()
{
    if [ -f "/etc/nginx/sites-enabled/default" ]; then
        rm -f /etc/nginx/sites-enabled/default
    fi

    if [ -f "/etc/nginx/sites-enabled/kibana.conf" ] && [ ! -f "/etc/nginx/kibana.auth" ]; then
        IFS=':'; credentials=($1); unset IFS;
        if [ ${#credentials[@]} -eq 1 ]; then
            username=${credentials[0]}
            password=$username
        elif [ ${#credentials[@]} -eq 2 ]; then
            username=${credentials[0]}
            password=${credentials[1]}
        else
            echo "[Nginx] invalid credentials in $1"
            exit 1
        fi
        htpasswd -b -c /etc/nginx/kibana.auth "$username" "$password"
        sed -i '/auth_basic/s/^\(\s*\)#/\1/g' /etc/nginx/sites-enabled/kibana.conf 
    fi
}

ensure_dir

if [ ! -f "$MYSQL_INITSQL" ] && [ -z "$MYSQL_SKIP_INIT" ]; then
    boot_mysql "$MYSQL_INITSQL"
fi

# KIBANA_AUTH: "username:password" or "username". password will be the same as username if omitted
if [ -n "$KIBANA_AUTH" ]; then
    init_nginx "$KIBANA_AUTH"
fi

exec "$@"