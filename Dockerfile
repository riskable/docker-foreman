############################################################
# Dockerfile that creates a container for running Foreman (nightly) on phusion/baseimage
# (which is just a modified version of Ubuntu)
#
# Recommended build command:
#
#   docker build -t foreman /path/to/Dockerfile/dir/.
#
# Recommended run command:
#
#   docker run -t --hostname="foreman.company.com" --name=foreman -p 8443:443 -p 8080:80 foreman
#
# That will expose Foreman on ports 8443 and 8080 with the given hostname (use your own).
############################################################

FROM phusion/baseimage
MAINTAINER Dan McDougall <daniel.mcdougall@liftoffsoftware.com>

# Ensure everything is installed and up-to-date
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --fix-missing
RUN apt-get -y upgrade && apt-get install -y wget git puppet \
    build-essential ruby ruby-dev rake libsqlite3-dev libvirt-dev \
    libmysqlclient-dev postgresql-server-dev-9.3 openssl libxml2-dev \
    libsqlite3-dev libxslt1-dev zlib1g-dev libreadline-dev

# Add the Foreman repos
RUN echo "deb http://deb.theforeman.org/ trusty nightly" > /etc/apt/sources.list.d/foreman.list
RUN echo "deb http://deb.theforeman.org/ plugins nightly" >> /etc/apt/sources.list.d/foreman.list
RUN wget -q http://deb.theforeman.org/pubkey.gpg -O- | apt-key add -
RUN apt-get update && apt-get -y install foreman-installer
RUN apt-get -y clean
RUN gem install sqlite3

# Copy our first_run.sh script into the container:
COPY first_run.sh /usr/local/bin/first_run.sh
RUN chmod 755 /usr/local/bin/first_run.sh
# Also copy our installer script
COPY install_foreman.sh /opt/install_foreman.sh
RUN chmod 755 /opt/install_foreman.sh

# Perform the installation
RUN bash /opt/install_foreman.sh
RUN rm -f /opt/install_foreman.sh # Don't need it anymore

# Expose our HTTP/HTTPS ports:
EXPOSE 80
EXPOSE 443

# Our 'first run' script which takes care of resetting the DB the first time
# the image runs with subsequent runs being left alone:
CMD ["/usr/local/bin/first_run.sh"]
