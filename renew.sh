#!/usr/bin/env bash
set -e

# begin configuration

domains=( nerdz.eu www.nerdz.eu )
email=nessuno@nerdz.eu
w_root=/home/nessuno/
user=root
group=www-data

# end configuration

if [ "$EUID" -ne 0 ]; then
    echo  "Please run as root"
    exit 1
fi


for domain in "${domains[@]}"; do
    /usr/local/bin/certbot-auto certonly --agree-tos --renew-by-default --email $email --webroot -w $w_root$domain -d $domain
    PEMFILE=`mktemp`
    cat /etc/letsencrypt/live/$domain/privkey.pem /etc/letsencrypt/live/$domain/cert.pem > $PEMFILE
    cp $PEMFILE /etc/lighttpd/$domain.pem
    cp /etc/letsencrypt/live/$domain/fullchain.pem /etc/lighttpd/
    chown $user:$group /etc/lighttpd/*.pem
    chmod 0640 /etc/lighttpd/*.pem
    rm $PEMFILE
done
