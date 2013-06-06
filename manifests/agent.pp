# == Class: puppet::agent
#
# Install, configure, and run a puppet agent instance.
#
# == Parameters
#
# [*server*]
#   The puppet server to use for fetching catalogs. Required.
# [*ca_server*]
#   The puppet server to use for certificate requests and similar actions.
#   Default: puppet::agent::server
# [*report_server*]
#   The puppet server to send reports.
#   Default: puppet::agent::server
# [*manage_repos*]
#   Whether to manage Puppet Labs APT or YUM package repos.
#   Default: true
# [*manage_service*]
#   Whether to manage the puppet agent service when using the cron run method.
#   Default: undef
# [*method*]
#   The mechanism for performing puppet runs.
#   Supported methods: [cron, service]
#   Default: cron
#
# == Example:
#
#   class { 'puppet::agent':
#     server        => 'puppet.example.com',
#     report_server => 'puppet_reports.example.com',
#     method        => 'service',
#  }
#
class puppet::agent(
  $server         = hiera('puppet::agent::server', 'puppet'),
  $ca_server      = hiera('puppet::agent::server', 'puppet'),
  $report_server  = hiera('puppet::agent::server', 'puppet'),
  $manage_repos   = true,
  $manage_service = undef,
  $method         = 'cron',
) {

  include puppet

  if $manage_repos {
    require puppet::package
  }

  case $method {
    cron:    { class { 'puppet::agent::cron': manage_service => $manage_service } }
    service: { include puppet::agent::service }
    default: {
      notify { "Agent run method \"${method}\" is not supported by ${module_name}, defaulting to cron": loglevel => warning }
      class { 'puppet::agent::cron': manage_service => $manage_service }
    }
  }

  Ini_setting {
    path    => $puppet::params::puppet_conf,
    ensure  => 'present',
    require => File[$puppet::params::puppet_conf],
  }

  ini_setting { 'server':
    section => 'main',
    setting => 'server',
    value   => $server,
  }

  ini_setting { 'ca_server':
    section => 'main',
    setting => 'ca_server',
    value   => $ca_server,
  }

  ini_setting { 'report_server':
    section => 'main',
    setting => 'report_server',
    value   => $report_server,
  }

  ini_setting { 'pluginsync':
    section => 'main',
    setting => 'pluginsync',
    value   => 'true'
  }

  ini_setting { 'logdir':
    section => 'main',
    setting => 'logdir',
    value   => $puppet::params::puppet_logdir,
  }

  ini_setting { 'vardir':
    section => 'main',
    setting => 'vardir',
    value   => $puppet::params::puppet_vardir,
  }

  ini_setting { 'ssldir':
    section => 'main',
    setting => 'ssldir',
    value   => $puppet::params::puppet_ssldir,
  }

  ini_setting { 'rundir':
    section => 'main',
    setting => 'rundir',
    value   => $puppet::params::puppet_rundir,
  }

  if $::operatingsystem == 'Ubuntu' {
    ini_setting { 'prerun_command':
      section => 'main',
      setting => 'prerun_command',
      value   => '/etc/puppet/etckeeper-commit-pre'
    }

    ini_setting { 'postrun_command':
      section => 'main',
      setting => 'postrun_command',
      value   => '/etc/puppet/etckeeper-commit-post'
    }
  }

  ini_setting { 'certname':
    section => 'agent',
    setting => 'certname',
    value   => $::clientcert,
  }

  ini_setting { 'report':
    section => 'agent',
    setting => 'report',
    value   => 'true',
  }

  ini_setting { 'environment':
    section => 'agent',
    setting => 'environment',
    value   => $::environment,
  }

  ini_setting { 'report':
    section => 'agent',
    setting => 'report',
    value   => 'true',
  }

  ini_setting { 'show_diff':
    section => 'agent',
    setting => 'show_diff',
    value   => 'true',
  }
  
  ini_setting { 'splay':
    section => 'agent',
    setting => 'splay',
    value   => 'false',
  }

  ini_setting { 'configtimeout':
    section => 'agent',
    setting => 'configtimeout',
    value   => '360',
  }

}
