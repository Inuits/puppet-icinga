# == Class: icinga::plugins::checkhaproxy
#
# This class provides a checkhaproxy plugin.
#
class icinga::plugins::checkhaproxy (
  $ensure                = present,
  $urls_to_check          = [ 'http://127.0.0.1/haproxy?stats' ],
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,

) inherits icinga {

  file { "${::icinga::plugindir}/check_haproxy.rb":
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/icinga/check_haproxy.rb',
    notify  => Service[$icinga::service_client],
    require => Class['icinga::config'];
  }

  file { "${::icinga::includedir_client}/haproxy.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => template('icinga/plugins/haproxy.cfg.erb'),
    notify  => Service[$::icinga::service_client],
  }

  create_resources('::icinga::plugins::checkhaproxy::nagios_service', $urls_to_check, {
    contact_groups        => $contact_groups,
    max_check_attempts    => $max_check_attempts,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  })

}

