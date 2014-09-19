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

/usr/sbin/foreman-installer --reset-foreman-db
foreman-rake db:migrate
foreman-rake db:seed
foreman-rake permissions:reset # This will display the admin password; NOTE IT

# Configure Foreman to start at boot
sed -i -e "s/START=no/START=yes/g" /etc/default/foreman

touch /etc/foreman/.first_run_completed

echo -e "\033[1mMAKE NOTE OF THAT PASSWORD\033[0m"
echo -e "\033[1mNOTE:\033[0m You may have to set the idle_timeout in Administer->Settings to something > 0 (not sure how to set that in this script)."
echo "Now starting a tail -f of the production.log..."
echo -e "\033[1mNOTE:\033[0m If you just ran 'docker run' you can safely ctrl-c now without killing the container."
exec /bin/bash -c "tail -1f /var/log/foreman/production.log"
exit 0
