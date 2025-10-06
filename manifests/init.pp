# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include lightspeed
#
# @param package_name
#   The name of the package to install.
#
# @param package_state
#   The installation state of $package_name.
#
# @param service_name
#   The name of the Lightspeed service daemon.
#
# @param service_enable
#   The state of the Lightspeed service clad.
#
# @param service_ensure
#   The state of the Lightspeed service clad.
#
# @param backend_endpoint
#   The URL to the AI Endpoint Server.
#
# @param logging_level
#   The logging level.
#
class lightspeed (
  Stdlib::HTTPUrl $backend_endpoint                     = 'https://satellite.redhat.com/api/lightspeed/v1',
  String[1] $package_name                               = 'command-line-assistant',
  String[1] $service_name                               = 'clad',
  Boolean $service_enable                               = true,
  Stdlib::Ensure::Service $service_ensure               = 'running',
  Enum['installed', 'present', 'absent'] $package_state = 'installed',
  Enum['INFO', 'DEBUG'] $logging_level                  = 'INFO'
) {
  $config_file_name = '/etc/xdg/command-line-assistant/config.toml'

  package { $package_name:
    ensure => $package_state,
  }

  file { $config_file_name:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0600',
    content => template('lightspeed/config.toml.erb'),
    require => Package[$package_name],
  }

  service { $service_name:
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => File[$config_file_name],
  }
}
