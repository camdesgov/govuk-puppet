# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class icinga::package {

  include govuk::ppa

  # icinga3-cgi has apache2 as a `Recommends:` so it may get unintentionally
  # installed. This gets rid of it in that eventually.
  include apache::remove

  include nginx::fcgi

  include ::perl::libwww

  package { [
    'icinga',
    'nagios-images',
    'nagios-plugins',
    'libcrypt-ssleay-perl',
    'libnet-ssleay-perl',
    'libio-socket-ssl-perl',
    'nagios-nrpe-plugin',
  ]:
    ensure => present,
  }

  # `nagios-nrpe-plugin` has `Recommends: nagios3`. May be fixed in 14.04
  # https://bugs.launchpad.net/ubuntu/+source/nagios-nrpe/+bug/927651
  include nagios::remove
  Package['nagios-nrpe-plugin'] -> Class['nagios::remove']

  package { 'check_graphite':
    ensure   => '0.2.2',
    provider => 'system_gem',
  }

  package { 'NagAconda':
    ensure   => present,
    provider => 'pip',
  }

  file { '/usr/local/bin/sendEmail':
    source => 'puppet:///modules/icinga/usr/local/bin/sendEmail',
    mode   => '0755',
  }

  # FIXME: Remove when this file has been purged from production
  file { '/usr/local/bin/reversedns.py':
    ensure => 'absent',
  }

  # pagerduty stuff
  file { '/usr/local/bin/pagerduty_nagios.pl':
    source => 'puppet:///modules/icinga/usr/local/bin/pagerduty_nagios.pl',
    mode   => '0755',
  }

  # FIXME: Remove once deployed to production
  file { '/usr/local/bin/pagerduty_icinga.pl':
    ensure => absent,
    source => 'puppet:///modules/icinga/usr/local/bin/pagerduty_icinga.pl',
    mode   => '0755',
  }

  file { '/var/log/sendEmail':
    ensure  => present,
    owner   => nagios,
    group   => nagios,
    require => Package['icinga']
  }

  #
  # The following execs ensure that the Nagios web interface can send commands
  # to the Nagios daemon, by adjusting the permissions on the FIFO they use to
  # communicate with each other. This cannot be achieved simply by modifying
  # the permissions with Puppet, as Nagios recreates the pipe when it starts,
  # and reads the correct permissions from dpkg.
  #   - NS 2013-01-09
  #
  exec { 'dpkg-statoverride /var/lib/icinga/rw':
    command => 'dpkg-statoverride --update --add nagios www-data 2710 /var/lib/icinga/rw',
    unless  => 'dpkg-statoverride --list /var/lib/icinga/rw',
    require => Package['icinga'],
  }

  exec { 'dpkg-statoverride /var/lib/icinga':
    command => 'dpkg-statoverride --update --add nagios nagios 751 /var/lib/icinga',
    unless  => 'dpkg-statoverride --list /var/lib/icinga',
    require => Package['icinga'],
    }
}
