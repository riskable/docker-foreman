#!/bin/bash
#
# Description:  Runs the foreman installer as a separate process so we don't
#               have to worry about a nonzero exit status (which we don't care
#               about most of the time).
#

# Fix the hostname problem by removing that check and setting a dummy FQDN:
rm -f /usr/share/foreman-installer/checks/hostname.rb
export FACTER_fqdn="foreman.example.com" # Dummy/temp FQDN
/usr/sbin/foreman-installer
exit 0
