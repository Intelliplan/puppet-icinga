# == Class: icinga::plugins::chechfilecount
#
# This class provides a checkfilecount plugin.
#
class icinga::plugins::checkfilecount (
  $pkgname               = 'nagios-plugins-file-count-1.0-0',
  $check_warning         = '1',
  $check_critical        = '0',
  $target_folder         = undef,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $contact_groups        = $::environment,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  package{$pkgname:
    ensure => 'installed',
  }

  file{"${::icinga::includedir_client}/check_file_count.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => "command[check_file_count]=sudo ${::icinga::plugindir}/check_file-count.sh -w ${check_warning} -c ${check_critical} -f ${target_folder}\n",
    notify  => Service[$::icinga::service_client],
  }

  @@nagios_service { "check_nginx_routing_file_count_${::fqdn}":
    check_command         => 'check_nrpe_command!check_file_count',
    service_description   => 'Routing files',
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    max_check_attempts    => $max_check_attempts,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    action_url            => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
  }
}
