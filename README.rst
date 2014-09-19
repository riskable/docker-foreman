docker-foreman
==============

A `Dockerfile <https://docs.docker.com/reference/builder/>`_ and supporting
scripts for running `Foreman <http://theforeman.org/>`_ inside a
`Docker <https://www.docker.com/>`_ container.  It is based on
`phusion/baseimage <https://registry.hub.docker.com/u/phusion/baseimage/>`_
which is a modified version of Docker's default 'ubuntu' image.

The image is configured to use the
`'nightly' Debian repository <http://theforeman.org/manuals/1.6/index.html#3.3.3DebianPackages>`_
because I could not get the 1.6 release working properly.

Note that I am not a Foreman expert (yet).  This Docker image was created so
that can happen :smile: .  If I've made a horrible mistake somewere please
`open an issue <https://github.com/riskable/docker-foreman/issues/new>`_.

Building
--------
It is recommended that to build this Docker image like so::

    docker build -t foreman /path/to/docker-foreman/.

This will create a new docker image named "foreman" using the Dockerfile in
this repository.  Replace ``/path/to/docker-foreman/.`` with the correct path on
your system.

Running
-------
It is recommended that you run the image like so::

    docker run -t --hostname="foreman.company.com" --name=foreman -p 8443:443 -p 8080:80 foreman

That will run the image in a new container with the hostname,
'foreman.company.com' (replace with your own hostname) named, 'foreman' with
ports 80 and 443 inside the container exposed as ports 8080 and 8443,
respectively.

The first time the container is run it will execute the
`first_run.sh <https://github.com/riskable/docker-foreman/blob/master/first_run.sh>`_
script which calls ``foreman-installer --reset-foreman-db`` and
``foreman-rake permissions:reset`` to reset the Foreman database and provide new
credentials for the 'admin' user.  These credentials will be displayed so make
sure to take a note of them so you can login after it's done starting up.

**NOTE:** The ``first_run.sh`` script only runs
``foreman-installer --reset-foreman-db`` *once*.  If you ``docker commit`` the
container (say, after an ``apt-get update && apt-get upgrade``) it will not
reset the database unless you remove the ``/etc/foreman/.first_run_completed``
file.

Known Issues
------------
There's some (mostly minor) issues with the image...

SmartProxy Errors
^^^^^^^^^^^^^^^^^
I have not tested Foreman's SmartProxy in this image so I don't know if it
works.  What I *do* know is that when you build the image ``foreman-installer``
will output errors like this::

    E, [2014-09-19T01:27:00.689495 #381] ERROR -- : ge: 365/366, 99%, 0.0/s, elapsed: 00:05:39
     /Stage[main]/Foreman_proxy::Register/Foreman_smartproxy[foreman.example.com]: Failed to call refresh: Could not load data from https://foreman.example.com
     /Stage[main]/Foreman_proxy::Register/Foreman_smartproxy[foreman.example.com]: Could not load data from https://foreman.example.com

I don't know what the consequences of that are are but I do believe it has
something to do with the fact that the hostname of the image isn't set to an
FQDN when the image is built.  I'm *hoping* that by passing the ``--hostname=``
option to ``docker run`` corrects the problem.  Maybe someone that knows more
about Foreman can provide more detail (
`open an issue <https://github.com/riskable/docker-foreman/issues/new>`_).

Tips
----

Install Plugins and Extra Tools
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Use the ``docker-enter`` command (if you don't have it follow the instructions
`here <https://github.com/jpetazzo/nsenter>`_) to enter the container then you
can install any of the packages/plugins in the official 'plugins' repository::

    root@foreman:~# apt-cache search foreman
    foremancli - commandline search interface to Foreman
    foreman-assets - metapackage providing Rails asset dependencies for Foreman
    foreman-cli - metapackage providing hammer CLI for Foreman
    foreman-compute - metapackage providing fog dependencies for Foreman (for Amazon EC2 support)
    foreman-console - metapackage providing console dependencies for Foreman
    foreman-devel - metapackage providing development dependencies for Foreman
    foreman-gce - metapackage providing GCE dependencies for Foreman
    foreman-installer - Automated puppet-based installer for The Foreman
    foreman-libvirt - metapackage providing libvirt dependencies for Foreman
    foreman-mysql2 - metapackage providing mysql2 dependencies for Foreman
    foreman-ovirt - metapackage providing ovirt dependencies for Foreman
    foreman-postgresql - metapackage providing PostgreSQL dependencies for Foreman
    foreman-proxy - RESTful proxies for DNS, DHCP, TFTP, and Puppet
    foreman-sqlite3 - metapackage providing sqlite dependencies for Foreman
    foreman-test - metapackage providing test dependencies for Foreman
    foreman-vmware - metapackage providing vmware dependencies for Foreman
    foreman - Systems management web interface
    ruby-foreman-api - Ruby bindings for Foreman's rest API
    ruby-hammer-cli-foreman-bootdisk - Foreman boot disk commands for Hammer CLI
    ruby-hammer-cli-foreman - Foreman commands for Hammer
    ruby-foreman-bootdisk - Foreman Bootdisk Plugin
    ruby-foreman-chef - Foreman Chef Plugin
    ruby-foreman-column-view - Foreman Column View Plugin
    ruby-foreman-deface - Foreman Deface Plugin Dependency
    ruby-foreman-default-hostgroup - Foreman Default Hostgroup Plugin
    ruby-foreman-dhcp-browser - Foreman DHCP browser Plugin
    ruby-foreman-discovery - Foreman Discovery Plugin
    ruby-foreman-hooks - Foreman Hooks Plugin
    ruby-foreman-salt - Foreman Salt Plugin
    ruby-foreman-setup - Foreman Setup Plugin
    ruby-foreman-snapshot - Foreman Snapshot Plugin
    ruby-foreman-templates - Foreman Templates Plugin
    ruby-puppetdb-foreman - Foreman Puppetdb Plugin
    ruby-smart-proxy-salt - SaltStack Plug-In for Foreman's Smart Proxy

**Example:** ``apt-get install ruby-foreman-column-view``

Enjoy!


