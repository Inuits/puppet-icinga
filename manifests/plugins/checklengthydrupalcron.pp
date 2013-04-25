# == Class: icinga::plugins::checklengthydrupalcron
#
# This class provides a checklengthydrupalcron plugin.
#
# All processes containing cron.php will be matched assuming it's a drupal site
#
# Warning and Critical expressed in seconds.  3600sec = 1h, 7200sec = 2h
define icinga::plugins::checklengthydrupalcron (
  $pkgname                = 'nagios-plugins-procs',
  $notification_period    = $::icinga::notification_period,
  $notifications_enabled  = $::icinga::notifications_enabled,
  $host_name              = $::fqdn,
  $warning                = '1800',
  $critical               = '3600',
) {

  require icinga

  if $icinga::client {

    if ! defined(Package[$pkgname]) {
      package{$pkgname:
        ensure => 'installed',
      }
    }

    file{"${::icinga::includedir_client}/check_lengthy_drupal_cron_${title}.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_lengthy_drupal_cron_${title}]=${::icinga::plugindir}/check_procs -m ELAPSED -a cron.php -w ${warning} -c ${critical}\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_lengthy_drupal_cron_${host_name}_${title}":
      check_command         => "check_nrpe_command!check_lengthy_drupal_cron_${title}",
      service_description   => "Check Long Running Drupal Cron ${title}",
      host_name             => $host_name,
      use                   => 'generic-service',
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${host_name}.cfg",
    }
  }
}