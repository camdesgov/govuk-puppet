# Creates the digitalassurancetester pentest user
class users::digitalassurancetester {
  govuk_user { 'digitalassurancetester':
    ensure   => absent,
    fullname => 'digitalassurancetester',
    email    => 'digitalassurancetester@digital.cabinet-office.gov.uk',
    ssh_key  => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/oSeiicmPjl46CWe6Ak4jYcD5QHa2asD9RfA8es+adQxuhbyolZHvvuplVFdTABCFm1Y0Y9XF+Y4jQjPtjObjil3h1Mycs2L7Lw6eaCvv55sYMlXSNRMWfjtB0bMX2T8Tj3ziuYuJR43pySRZGUaWqwukBva37VI1PjhWzapxo/WP3D6syWBu+Mq0yEAqqG+T5Zr1NH0FdSnsAN7vcbdKnPEMYzYK+LI3lTPuDiu3BXxFPQnDepAlqBRksSF5L8m6VDEyuVDVi0vjYckSDU5L7RQU9gjV55LAGgkyv5vVgfddjzcXa8s/J/ob5XNZLiPwKtBpEj+c9eZZsez9mBfb5/hTLK80gFxf5lLN6wQ7UYOILkuWtnoutPCBfKjuqFj5V8qZFc/PTZtXQrL9or3qxQ0NjkHxf5HhduXcbv6NkvGYJn3AnJPo2uGldAbhinBjeHcQRRcknK0xzye7EEUPPmrVg6sqth4ExnUElcqjZpzCMPriyNmE9ng7g7A5oz6KCgsk9cuZFdmV2TqHfM35sRiMjoIVtt+/c3H6vxsha1FtgNcr55CqVSbsTQJpdMP4b8O1nLeAJOKyuounWQKRYJdvRM+RDylo/JF3s/p9Vav+ZcaLQoIhQ6X1KuTSCa21914HmBJwK63O1sjBKl6epWQaU9jcekueS0lWRolO0w==',
  }
}
