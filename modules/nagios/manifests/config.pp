class nagios::config {

  file { '/etc/nagios3/conf.d/check_ganglia_nagios2.cfg':
    source  => 'puppet:///modules/nagios/etc/nagios3/check_ganglia_nagios2.cfg',
  }

  file { '/etc/nagios3/conf.d/generic-host_nagios2.cfg':
    source  => 'puppet:///modules/nagios/etc/nagios3/generic-host_nagios2.cfg',
  }

  file { '/etc/nagios3/conf.d/check_http_nagios2.cfg':
    source  => 'puppet:///modules/nagios/etc/nagios3/check_http_nagios2.cfg',
  }

  file { '/etc/nagios3/conf.d/check_smokey.cfg':
    source  => 'puppet:///modules/nagios/etc/nagios3/check_smokey.cfg',
  }

  @@nagios::check {'check_smokey':
    check_command       => 'run_smokey_tests',
    service_description => 'Run small suite of functional tests',
    host_name           => "${::govuk_class}-${::hostname}"
  }

  nagios::timeperiod { '24x7':
    timeperiod_alias => '24 Hours A Day, 7 Days A Week',
    sun              => '00:00-24:00',
    mon              => '00:00-24:00',
    tue              => '00:00-24:00',
    wed              => '00:00-24:00',
    thu              => '00:00-24:00',
    fri              => '00:00-24:00',
    sat              => '00:00-24:00',
  }

  nagios::timeperiod { 'workhours':
    timeperiod_alias => 'Standard Work Hours',
    mon              => '09:00-17:00',
    tue              => '09:00-17:00',
    wed              => '09:00-17:00',
    thu              => '09:00-17:00',
    fri              => '09:00-17:00',
  }

  nagios::timeperiod { 'nonworkhours':
    timeperiod_alias => 'Non-Work Hours',
    sun              => '00:00-24:00',
    mon              => '00:00-09:00,16:00-24:00',
    tue              => '00:00-09:00,16:00-24:00',
    wed              => '00:00-09:00,16:00-24:00',
    thu              => '00:00-09:00,16:00-24:00',
    fri              => '00:00-09:00,17:00-24:00',
    sat              => '00:00-24:00',
  }

  nagios::timeperiod { 'never':
    timeperiod_alias => 'Never'
  }

  file { '/etc/nagios3/cgi.cfg':
    source => 'puppet:///modules/nagios/etc/nagios3/cgi.cfg',
  }

  file { '/etc/nagios3/conf.d/hostgroups_nagios2.cfg':
    source => 'puppet:///modules/nagios/etc/nagios3/conf.d/hostgroups_nagios2.cfg',
  }

  #TODO: extlookup or hiera for email addresses?

  case $::govuk_provider {
    sky: {
      $contact_email = $::govuk_platform ? { 
        production   => 'monitoring-skyprod+pager@digital.cabinet-office.gov.uk',
        default      => 'root@localhost',
      }
    }
    default: {
      $contact_email = $::govuk_platform ? {
        production   => 'monitoring-ec2production+pager@digital.cabinet-office.gov.uk',
        preview      => 'monitoring-ec2preview+pager@digital.cabinet-office.gov.uk',
        default      => 'root@localhost',
      }
    }
  }

  nagios::contact { 'monitoring_google_group':
    email => $contact_email
  }

  case $::govuk_provider {
    sky: {
      $pager_fake_email = $::govuk_platform ? {
          production    => 'monitoring-skyprod+pager@digital.cabinet-office.gov.uk',
          default       => 'root@localhost',
      }
    }
    default: {
      $pager_fake_email = $::govuk_platform ? {
          production    => 'monitoring-ec2production+pager@digital.cabinet-office.gov.uk',
          preview       => 'monitoring-ec2preview+pager@digital.cabinet-office.gov.uk',
          default       => 'root@localhost',
      }
    }
  }

  nagios::contact { 'pager_workhours':
    email                        => $pager_fake_email,
    service_notification_options => 'c',
    notification_period          => 'workhours'
  }

  nagios::contact { 'pager_nonworkhours':
    email                        => $pager_fake_email,
    service_notification_options => 'c',
    notification_period          => 'nonworkhours',
    config_template              =>  'nagios/pager_nonworkhours.cfg.erb'
  }

  nagios::contact_group { 'emergencies':
    group_alias => 'Contacts for emergency situations',
    members     => ['monitoring_google_group','pager_nonworkhours','pager_workhours'],
  }

  nagios::contact_group { 'regular':
    group_alias => 'Contacts for regular alerts',
    members     => ['monitoring_google_group'],
  }

  nagios::service_template { 'govuk_emergency_service':
    contact_groups => ['emergencies']
  }

  nagios::service_template { 'govuk_regular_service':
    contact_groups => ['regular']
  }

  file { '/etc/nagios3/resource.cfg':
    source  => 'puppet:///modules/nagios/etc/nagios3/resource.cfg',
  }

  file { '/etc/nagios3/commands.cfg':
    source  => 'puppet:///modules/nagios/etc/nagios3/commands.cfg',
  }

  file { '/etc/nagios3/nagios.cfg':
    source  => 'puppet:///modules/nagios/etc/nagios3/nagios.cfg',
  }

  file { '/etc/nagios3/htpasswd.users':
    source  => 'puppet:///modules/nagios/etc/nagios3/htpasswd.users',
  }

  file { '/etc/nagios3/apache2.conf':
    source => 'puppet:///modules/nagios/etc/nagios3/apache2.conf',
  }

  file { '/etc/apache2/conf.d/nagios3.conf':
    ensure  => link,
    target  => '/etc/nagios3/apache2.conf',
    require => Service[apache2]
  }

  cron { 'pagerduty':
    command => '/usr/local/bin/pagerduty_nagios.pl flush',
    user    => 'nagios',
    minute  => '*',
  }

  user { 'www-data':
    groups => ['nagios'],
  }

  # it's possible this is still missing running
  # dpkg-statoverride --update --add nagios www-data 2710 /var/lib/nagios3/rw
  # dpkg-statoverride --update --add nagios nagios 751 /var/lib/nagios3
}
