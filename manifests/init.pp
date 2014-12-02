# == Class: sssd
# Manage SSSD authentication on RHEL-based systems.
#
# === Parameters
# [*domains*]
# Required. Array. For each sssd::domain type you declare, you SHOULD also
# include the domain name here. This defines the domain lookup order.
#
# [*services*]
# Required. Array. Default is ['nss', 'pam']. For each sssd::service type 
# you declare, you SHOULD also include the service name here.
#
# [*options*]
# Optional. Hash. Default is an empty hash. Key/value pairs will be used to 
# set options underneath the [sssd] section in /etc/sssd/sssd.conf.
#
# [*sections*]
# Optional. Hash. Default is a hash from sssd::params. The typical way of 
# setting up services for SSSD is by using the sssd::service defined type. 
# That poses a problem if you want to use Hiera for storing your configuration 
# data. This parameter allows you to pass a hash that is used to automatically 
# instantiate sssd::service types.
#
# [*backends*]
# Optional. Hash. Default is an empty hash. The typical way of setting up 
# backends for SSSD is by using the sssd::domain defined type. That poses 
# a problem if you want to use Hiera for storing your configuration data. 
# This parameter allows you to pass a hash that is used to automatically 
# instantiate sssd::domain types.
#
# [*make_home_dir*]
# (true|false) Optional. Boolean. Default is false. Enable this if you
# want network users to have a home directory created when they login. For now,
# this option is only available for RedHat family machines.
#
# [*packages*]
# Optional. Default comes from sssd::params based on osfamily fact. 
# You can override which packages this module installs with this parameter.
# Be sure to use an array if it's more than one package.
#
# [*manage_cron*]
# (true|false) Optional. Boolean. Default is true. This parameter will
# toggle whether or not this module attempts to restart the cron service
# everytime the sssd service is restarted.
#
# === Requires
# - [puppetlabs/concat]
# - [puppetlabs/stdlib]
#
# === Example
# class { 'sssd':
#   domains => [ 'mydomain.com' ],
#   options => { 'sbus_timeout' => '30' },
# }
#
# === Authors
# Nicholas Waller <code@nicwaller.com>
# Riley Shott <rshott@sfu.ca>
#
# === Copyright
# Copyright 2013 Nicholas Waller
# Copyright 2014 Simon Fraser University
#
class sssd (
  $domains,
  $services      = ['nss', 'pam'],
  $options       = {},
  $sections      = $sssd::params::sections,
  $backends      = {},
  $make_home_dir = false,
  $packages      = $sssd::params::packages,
  $manage_cron   = true,
) inherits sssd::params {
  validate_array($domains)
  validate_array($services)
  validate_hash($options)
  validate_hash($sections)
  validate_hash($backends)
  validate_bool($make_home_dir)
  validate_bool($manage_cron)

  unless empty($backends) {
    create_resources('sssd::domain', $backends)
  }

  package { $packages:
    ensure => installed,
  }
  
  concat { 'sssd_conf':
    path    => '/etc/sssd/sssd.conf',
    mode    => '0600',
    # SSSD fails to start if file mode is anything other than 0600
    require => Package[$packages],
  }
  
  concat::fragment{ 'sssd_conf_header':
    target  => 'sssd_conf',
    content => template('sssd/header_sssd.conf.erb'),
    order   => 10,
  }
  
  unless empty($sections) {
    create_resources('sssd::service', $sections)
  }

  # Until further testing
  if ($make_home_dir and $::osfamily != 'Debian') {
    class { 'sssd::homedir': }
  }

  exec { 'authconfig-sssd':
    command     => $sssd::params::authconfig_sssd,
    refreshonly => true,
    subscribe   => Concat['sssd_conf'],
  }
  
  service { 'sssd':
    ensure      => running,
    enable      => true,
    subscribe   => Exec['authconfig-sssd'],
  }
  
  if $manage_cron {
    service { $sssd::params::cron_service:
      subscribe => Service['sssd'],
    }
  }
}
