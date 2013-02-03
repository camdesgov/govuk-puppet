class jenkins {
  #TODO:
  # also need to install fabric and cloth which are needed by private-utils,
  # possibly this would be better done in the private-utils/jenkins.sh

  user { 'jenkins':
    ensure     => present,
    home       => '/home/jenkins',
    managehome => true,
    shell      => '/bin/bash'
  }

  # This facter fact can be set on slave machines to signal that the slave should install and
  # use java 7 rather than java 6.
  if $::govuk_java_version == 'oracle7' {

    include java::oracle7::jdk
    include java::oracle7::jre

    class { 'java::set_defaults':
      jdk => 'oracle7',
      jre => 'oracle7',
    }

  } else {

    include java::sun6::jdk
    include java::sun6::jre

    class { 'java::set_defaults':
      jdk => 'sun6',
      jre => 'sun6',
    }

  }

  package { 'brakeman':
    ensure   => 'installed',
    provider => gem,
  }

  include nginx
  include jenkins::ssh_key

  package { [
    'sqlite3',
    'gnuplot',
    'python-virtualenv',
    'python-paramiko',
    'ant'
    ]:
      ensure => installed,
  }

  # Required for redirector-deploy
  package { 's3cmd':
    ensure   => 'installed',
    provider => 'pip',
  }

  # This is required for the redirector-deploy job
  package { 'libtext-csv-perl':
    ensure => installed,
  }

  # This is required for the redirector-integration job
  package { 'libcrypt-ssleay-perl':
    ensure => installed,
  }

  # This is required for the gov.uk spider job
  package { 'scrapy':
    ensure   => '0.14.4',
    provider => 'pip',
  }

  package { 'twisted':
    ensure   => '10.0.0',
    provider => 'pip',
  }

  file { '/home/jenkins/.gitconfig':
    source  => 'puppet:///modules/jenkins/dot-gitconfig',
    owner   => jenkins,
    group   => jenkins,
    mode    => '0644',
    require => User['jenkins'],
  }

  file { '/mnt/jenkins':
    ensure  => directory,
    owner   => jenkins,
    group   => jenkins,
    mode    => '0644',
    require => User['jenkins'],
  }

  file { '/var/lib/jenkins':
    ensure  => link,
    target  => '/mnt/jenkins',
    require => File['/mnt/jenkins'],
  }
}

class jenkins::master inherits jenkins {

  $app_domain = extlookup('app_domain')

  apt::repository { 'jenkins':
    url  => 'http://pkg.jenkins-ci.org/debian',
    dist => '',
    repo => 'binary/',
    key  => 'D50582E6', # Kohsuke Kawaguchi <kk@kohsuke.org>
  }

  package { 'jenkins':
    ensure  => 'latest',
    require => User['jenkins'],
  }

  service { 'jenkins':
    ensure  => 'running',
    require => Package['jenkins'],
  }

  package { 'keychain':
    ensure => 'installed'
  }

  nginx::config::site { 'jenkins':
    content => template('jenkins/nginx.conf.erb'),
  }

  file { '/home/jenkins/.bashrc':
    source  => 'puppet:///modules/jenkins/dot-bashrc',
    owner   => jenkins,
    group   => jenkins,
    mode    => '0700',
    require => Package['keychain'],
  }

  file { '/var/govuk-archive':
    ensure  => directory,
    owner   => jenkins,
    group   => jenkins,
    require => User['jenkins'],
  }

  # Set the session timeout in Jenkins' web.xml file (installed by the
  # package). This is a bit nasty, as it just searches for the </description>
  # closing tag and inserts the session timeout customisation on the next
  # line, but it works...

  $jenkins_web_xml = '/var/cache/jenkins/war/WEB-INF/web.xml'
  $jenkins_session_timeout_min = 24 * 60

  exec { 'jenkins-set-session-timeout':
    command => "sed -i '/<\\/description>/a\\\n  <session-config><session-timeout>${jenkins_session_timeout_min}</session-timeout></session-config>' '${jenkins_web_xml}'",
    unless  => "fgrep -q '<session-timeout>' '${jenkins_web_xml}'",
    notify  => Service['jenkins'],
  }
}

class jenkins::slave inherits jenkins {
}
