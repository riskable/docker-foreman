#!/bin/bash

# Configures Foreman the first time using the hostname passed via:
#
#    sudo docker run --hostname="foreman.company.com" --name=formeman foreman
#
# Replace "foreman.company.com" with your forman server's real FQDN
# when running 'docker run.
#
# After this script has been run once it will simply execute a tail -f on
# Foreman's production.log file (mostly so that it doesn't just shut down the
# container right away).
#

if [ -f "/etc/foreman/.first_run_completed" ]; then
    exec /bin/bash -c "tail -50f /var/log/foreman/production.log"
    exit 0
fi
echo "FIRST-RUN: Please wait while Foreman is configured..."

# Copy the SSL key/cert for PostgreSQL so we don't get permissions errors
mkdir -p /etc/ssl/postgresql/{private,certs}
cp /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/postgresql/certs/
cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/postgresql/private/
chmod 640 /etc/ssl/postgresql/private/ssl-cert-snakeoil.key
chmod 750 /etc/ssl/postgresql/private
chown -R postgres /etc/ssl/postgresql

# Change PostgreSQL's ssl settings to reflect the new locations:
sed -i -e "/ssl_cert_file/s/certs/postgresql\/certs/g" \
    -e "/ssl_key_file/s/private/postgresql\/private/g" \
    /etc/postgresql/9.3/main/postgresql.conf

/etc/init.d/postgresql restart

/usr/sbin/foreman-installer --reset-foreman-db
foreman-rake db:migrate
foreman-rake db:seed
foreman-rake permissions:reset # This will display the admin password; NOTE IT

# Fix the missing idle_timeout value so we don't get logged out after each page
su - postgres <<'EOF'
psql -d foreman -c "update settings set value = 60 where settings.name = 'idle_timeout';"
EOF

# Configure Foreman to start at boot
sed -i -e "s/START=no/START=yes/g" /etc/default/foreman

touch /etc/foreman/.first_run_completed

echo -e "\033[1mMAKE NOTE OF THAT PASSWORD\033[0m"
echo -e "\033[1mNOTE:\033[0m You may have to set the idle_timeout in Administer->Settings to something > 0 (not sure how to set that in this script)."
echo "Now starting a tail -f of the production.log..."
echo -e "\033[1mNOTE:\033[0m If you just ran 'docker run' you can safely ctrl-c now without killing the container."
exec /bin/bash -c "tail -1f /var/log/foreman/production.log"
exit 0
