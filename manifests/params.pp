# == Class: sssd::params
# Set up parameters that vary based on platform or distribution.
#
# === Examples
# class { 'sssd::params': }
#
# === Authors
# Nicholas Waller <code@nicwaller.com>
# Riley Shott <rshott@sfu.ca>
#
# === Copyright
# Copyright 2013 Nicholas Waller
# Copyright 2014 Simon Fraser University 
#
class sssd::params {
  case $::osfamily {
    'Debian': {
      $sections = { 
                    'nss' => {
                      'options' => {
                        'filter_groups' => 'root',
                        'filter_users'  => 'root',
                      },
                    }, 
                    'pam' => { 
                      'options' => {}
                    },
                  }
      $package = [ 'sssd',
                   'libnss-sss',
                   'libpam-sss' ]
      $authconfig_sssd = '/bin/true'
      $cron_service = 'cron'
    }
    'RedHat': {
      # Must be a hash of hashes
      $sections = { 
                    'nss' => {
                      'options' => {
                        'filter_groups' => 'root',
                        'filter_users'  => 'root',
                      },
                    }, 
                    'pam' => { 
                      'options' => {}
                    },
                  }
      $package = 'sssd'
      $authconfig_sssd = '/usr/sbin/authconfig --enablesssd --enablesssdauth --enablelocauthorize --update'
      $cron_service = 'crond'
    }
    default: {
      fail('Unsupported distribution')
    }
  }
}
