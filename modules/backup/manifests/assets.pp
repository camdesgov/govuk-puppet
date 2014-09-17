# == backup::assets
#
#    This class backs up assets from Whitehall and asset-manager
#    using the Duplicity module.
#
# == Parameters
#
#    $target
#      Destination target prefix for backed-up data. Will append individual
#      back-up directories to this.
#
#    $pubkey_id
#      Fingerprint of the public GPG key used for encrypting the back-ups
#      against
#
#    $backup_private_key
#      Private key of the off-site backup box. Used in the deployment repo,
#      drawn in here
class backup::assets(
  $target,
  $pubkey_id,
  $backup_private_key,
) {

  $sshkey_file = '/root/.ssh/id_rsa'

  file { '/root/.ssh' :
    ensure => directory,
    mode   => '0700',
  }

  file { $sshkey_file :
    ensure  => present,
    mode    => '0600',
    content => $backup_private_key,
  }

  backup::assets::job { 'whitehall':
    asset_path => '/mnt/uploads/whitehall',
    target     => "${target}/whitehall",
    hour       => 4,
    minute     => 20,
    pubkey_id  => $pubkey_id,
    ssh_id     => $sshkey_file
  }

  backup::assets::job { 'asset-manager':
    asset_path => '/mnt/uploads/asset-manager',
    target     => "${target}/asset-manager",
    hour       => 4,
    minute     => 13,
    pubkey_id  => $pubkey_id,
    ssh_id     => $sshkey_file
  }

  # FIXME: Remove me once deployed
  file { '/usr/local/bin/memstore-backup.sh':
    ensure  => absent,
  }

  # FIXME: Remove me once deployed
  file { '/etc/govuk/memstore-credentials':
    ensure  => absent,
  }

  # FIXME: Remove me once deployed
  cron {[
    'backup-asset-manager',
    'backup-whitehall-draft-incoming',
    'backup-whitehall-draft-clean',
    'backup-whitehall-incoming',
    'backup-whitehall-clean'
    ]:
    ensure => absent
  }
}
