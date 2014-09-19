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

# Ensures apt doesn't ask us silly questions:
ENV DEBIAN_FRONTEND noninteractive

# Add the Foreman repos
RUN echo "deb http://deb.theforeman.org/ trusty nightly" > /etc/apt/sources.list.d/foreman.list
RUN echo "deb http://deb.theforeman.org/ plugins nightly" >> /etc/apt/sources.list.d/foreman.list
RUN curl http://deb.theforeman.org/pubkey.gpg | apt-key add -
RUN apt-get update --fix-missing && apt-get -y upgrade && \
    apt-get -y install git puppet apache2 build-essential ruby ruby-dev rake \
    facter bundler postgresql-9.3 postgresql-client-9.3 python \
    postgresql-server-dev-9.3 libxml2-dev libxslt1-dev libvirt-dev \
    foreman-installer foreman-cli foreman-postgresql
RUN apt-get -y clean

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
