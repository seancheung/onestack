#!/bin/bash

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

# KIBANA_AUTH: "username:password" or "username". password will be the same as username if omitted
if [ -n "$KIBANA_AUTH" ]; then
    init_nginx "$KIBANA_AUTH"
fi

exec /entrypoint.sh "$@"