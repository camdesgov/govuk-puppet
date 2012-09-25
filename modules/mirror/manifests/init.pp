class mirror {

  include wget

  file { '/usr/local/bin/govuk_update_mirror':
    ensure => present,
    mode   => '0755',
    source => 'puppet:///modules/mirror/govuk_update_mirror'
  }

  file { '/var/lib/govuk_mirror':
    ensure => directory,
  }

  cron { 'update-latest-to-mirror':
    ensure  => present,
    user    => 'root',
    hour    => '0',
    minute  => '0',
    command => '/usr/local/bin/govuk_update_mirror',
    require => File['/usr/local/bin/govuk_update_mirror'],
  }

}
