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
    }
    default: {
      fail('Unsupported distribution')
    }
  }
}
