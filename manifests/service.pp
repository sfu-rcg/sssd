# == Define: sssd::service
# This type is used to define one or more SSSD service [sections] in
# /etc/sssd/sssd.conf.
#
# === Parameters
# [*options*]
# Required. Hash. Top-level keys will be used to set [sections] headers in 
# /etc/sssd/sssd.conf. The Key/value pairs stemming from these top-level 
# keys will be used to set options underneath that section.
#
# [*sssd_service*]
# Optional. String. Defaults to using the name parameter. Sets the name for the
# service's [header] section. Supported services include: nss, pam, sudo, 
# autofs, ssh, pac.
#
# [*concat order*]
# Optional. String. Defaults to '30'. This will be passed to the 
# concat::fragment resource to set the order attribute.
#
# === Requires
# - [ripienaar/concat]
# - [puppetlab/stdlib]
#
# === Example
# sssd::service { 'nss':
#   'options' => {
#     'filter_groups'        => 'root',
#     'filter_users'         => 'root',
#     'reconnection_retries' => '3',
#   },
# }
#
# === Authors
# Riley Shott <rshott@sfu.ca>
#
# === Copyright
# Copyright 2014 Simon Fraser University 
#
define sssd::service (
  $options,
  $sssd_service = $name,
  $concat_order = '20',
) {
  validate_hash($options)
  validate_re($sssd_service, ['^nss', '^pam', '^sudo', '^autofs', '^ssh', '^pac'], "${name} does not match a supported service.")
  
  concat::fragment { "sssd_service_${name}":
    target  => 'sssd_conf',
    content => template('sssd/service_sssd.conf.erb'),
    order   => $concat_order,
  }
  
}
