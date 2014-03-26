class govuk::node::s_mysql_master ( $mysql_bouncer = '', )inherits govuk::node::s_base {
class govuk::node::s_mysql_master (
  $dump_password
) inherits govuk::node::s_base {
  $root_password = extlookup('mysql_root', '')
  $replica_password = hiera('mysql_replica_password', '')
class govuk::node::s_mysql_master inherits govuk::node::s_base {
  $root_password = hiera('mysql_root', '')
  $replica_password = extlookup('mysql_replica_password', '')

  class { 'govuk_mysql::server':
    root_password => $root_password,
  }
  class { 'govuk_mysql::server::master':
    replica_pass => $replica_password,
  }

  class { [
    'govuk::apps::contacts::db',
    'govuk::apps::content_planner::db',
    'govuk::apps::need_o_tron::db',
    'govuk::apps::release::db',
    'govuk::apps::search_admin::db',
    'govuk::apps::signon::db',
    'govuk::apps::tariff_admin::db',
    # FIXME: tariff_api::db is ensured absent. It can be removed once the DB has gone everywhere
    'govuk::apps::tariff_api::db',
    'govuk::apps::tariff_api_temporal::db',
    'govuk::apps::transition::db',
    'govuk::apps::whitehall::db'
    ]:
  }

  govuk_mysql::user { 'whitehall_fe@%':
    password_hash => mysql_password(extlookup('mysql_whitehall_frontend', '')),
    table         => 'whitehall_production.*',
    privileges    => ['SELECT'],
    require       => Class['govuk::apps::whitehall::db'],
  }

  govuk_mysql::user { 'bouncer@%':
    password_hash => mysql_password($mysql_bouncer),
    table         => 'transition_production.*',
    privileges    => ['SELECT'],
    require       => Class['govuk::apps::transition::db'],
  }

  govuk_mysql::user { 'dump@localhost':
    password_hash => mysql_password($dump_password),
    table         => '*.*',
    privileges    => ['SELECT', 'LOCK TABLES', 'SHOW DATABASES'],
  }

  collectd::plugin::tcpconn { 'mysql':
    incoming => 3306,
    outgoing => 3306,
  }

  #FIXME: remove if when we have moved to platform one
  if hiera(use_hiera_disks,false) {
    Govuk::Mount['/var/lib/mysql'] -> Class['govuk_mysql::server']
  }
}
