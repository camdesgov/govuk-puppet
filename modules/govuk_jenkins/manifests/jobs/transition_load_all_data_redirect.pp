# == Class: govuk_jenkins::jobs::transition_load_all_data_redirect
#
# Create a file on disk that can be parsed by jenkins-job-builder
#
class govuk_jenkins::jobs::transition_load_all_data_redirect {
  file { '/etc/jenkins_jobs/jobs/transition_load_all_data.yaml':
    ensure  => present,
    content => template('govuk_jenkins/jobs/transition_load_all_data_redirect.yaml.erb'),
    notify  => Exec['jenkins_jobs_update'],
  }
}
