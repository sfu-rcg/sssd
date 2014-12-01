# == Define: sssd::domain
# This type is used to define one or more domains which SSSD
# will authenticate against.
#
# === Parameters
# [*options*]
# Required. Hash. Key/value pairs will be used to set options underneath a 
# [domain/name] section in /etc/sssd/sssd.conf.
#
# [*ldap_domain*]
# Optional. String. Fully-qualified DNS name of your LDAP domain.
# Defaults to using the name parameter.

# [*ldap_tls_cacert*]
# Optional. String. If desired, you can specify a file containing trusted 
# Certificate Authorities. Otherwise, sssd will use the OpenLDAP defaults 
# in /etc/openldap/ldap.conf.
#
# [*concat order*]
# Optional. String. Defaults to '30'. This will be passed to the 
# concat::fragment resource to set the order attribute.
# === Requires
# - [ripienaar/concat]
# - [puppetlab/stdlib]
#
# === Example
# sssd::domain { 'mydomain.com':
#   options => {
#     'ldap_uri'                    => 'ldap://mydomain.com',
#     'ldap_search_base'            => 'DC=mydomain,DC=com',
#     'ldap_user_search_base        => 'DC=mydomain,DC=com',
#     'ldap_group_search_base       => 'DC=mydomain,DC=com',
#     'ldap_netgroup_search_base    => 'DC=mydomain,DC=com',
#     'krb5_realm'                  => 'MYDOMAIN.COM',
#     'ldap_default_bind_dn'        => 'CN=SssdService,DC=mydomain,DC=com',
#     'ldap_default_authtok'        => 'My ultra-secret password',
#     'simple_allow_groups'         => 'SssdAdmins',
#     'ldap_user_object_class'      => 'user',
#     'ldap_user_name'              => 'sAMAccountName',
#     'ldap_user_principal'         => 'userPrincipalName',
#     'ldap_user_uid_number'        => 'uidNumber',
#     'ldap_user_gid_number'        => 'gidNumber',
#     'ldap_user_gecos'             => 'gecos',
#     'ldap_user_shell'             => 'loginShell',
#     'ldap_user_home_directory'    => 'unixHomeDirectory',
#     'ldap_group_object_class'     => 'group',
#     'ldap_group_name'             => 'cn',
#     'ldap_group_member'           => 'member',
#     'ldap_group_gid_number'       => 'gidNumber',
#     'ldap_id_use_start_tls'       => 'True',
#     'ldap_tls_reqcert'            => 'demand',
#     'ldap_default_authtok_type'   => 'password',
#     'ldap_schema'                 => 'rfc2307bis',
#     'enumerate'                   => 'False',
#     'ldap_force_upper_case_realm' => 'True',
#     'ldap_referrals'              => 'False',
#     'cache_credentials'           => 'False',
#     'min_id'                      => '500',
#     'entry_cache_timeout'         => '60',
#     'krb5_canonicalize'           => 'False',
#   },
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
define sssd::domain (
  $options,
  $ldap_domain     = $name,
  $ldap_tls_cacert = undef,
  $concat_order    = '30',
) {
  validate_hash($options)
  validate_string($concat_order)

  if ($ldap_tls_cacert != undef) {
    $certdata = regsubst($ldap_tls_cacert, '[\n]', '', 'MG')
    validate_re($certdata, '^-----BEGIN CERTIFICATE-----.*END CERTIFICATE-----$')
    file { '/etc/sssd/cacerts':
      ensure  => directory,
      mode    => '0500',
    }
    $ldap_tls_cacert_path = "/etc/sssd/cacerts/${ldap_domain}"
    file { $ldap_tls_cacert_path:
      ensure  => present,
      content => $ldap_tls_cacert,
      mode    => '0400',
      before  => Concat::Fragment["sssd_domain_${ldap_domain}"],
    }
  }

  concat::fragment { "sssd_domain_${ldap_domain}":
    target  => 'sssd_conf',
    content => template('sssd/domain.conf.erb'),
    order   => $concat_order,
  }
}
