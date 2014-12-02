# sssd

####Table of Contents
1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Quick Start](#quick-start)
4. [Usage - Configuration options and additional functionality](#usage)
  * [Different attribute schema](#different-attribute-schema)
  * [Automatically create home directories](#automatically-create-home-directories)
  * [Authenticate against multiple domains](#authenticate-against-multiple-domains)
5. [Parameters](#parameters)
  * [Class: sssd](#class-sssd)
  * [Define Type: sssd::service](#define-type-sssdservice)
  * [Define Type: sssd::domain](#define-type-sssddomain)
6. [Development](#development)
7. [Special Acknowledgements](#special-acknowledgements)

## Overview
The SSSD module makes it easy to authenticate against Active Directory with sssd.

## Module Description
The SSSD module manages the sssd service on distributions based on RedHat Enterprise Linux 5 or 6, and has rudimentary Debian support (i.e. it can be improved). It is designed to work with Active Directory, but
can easily be customized to work with other LDAP servers. It also helps automate home directory creation.

SSSD module dependencies:

* puppetlabs/concat
* puppetlabs/stdlib

## Quick Start
I just want to login with my network username. What's the minimum I need?

```puppet
class { 'sssd':
  domains       => [ 'mydomain.com' ],
  services      => ['nss', 'pam'],
  make_home_dir => true,
}
sssd::domain { 'mydomain.com':
  options => {
    'ldap_uri'             => 'ldap://mydomain.com',
    'ldap_search_base'     => 'DC=mydomain,DC=com',
    'krb5_realm'           => 'MYDOMAIN.COM',
    'ldap_default_bind_dn' => 'CN=SssdService,DC=mydomain,DC=com',
    'ldap_default_authtok' => 'My ultra-secret password',
    'simple_allow_groups'  => 'SssdAdmins, DomainAdmins',
  },
}
```

Note that you must have certificates configured appropriate on your system so
that a secure TLS connection can be established with your LDAP server. On
RedHat-based systems, you need to install certificates of your trusted
certificate authority into `/etc/openldap/certs` and then hash the certs by
running `cacertdir_rehash /etc/openldap/certs`.

A certificate's content should be specified using the ldap_tls_cacert parameter in the domain define type.

## Usage

### Different attribute schema
Most LDAP servers use standard attribute names defined in rfc2307. This
includes Windows Server since 2003 R2. If your directory uses a non-standard
schema for posix accounts, you will need to define a custom attribute mapping.

```puppet
sssd::domain { 'mydomain.com':
  options => {
    ...
    ldap_user_object_class'   => 'user',
    ldap_user_name'           => 'sAMAccountName',
    ldap_user_principal'      => 'userPrincipalName',
    ldap_user_gecos'          => 'MSSFU2x-gecos',
    ldap_user_shell'          => 'MSSFU2x-loginShell',
    ldap_user_uid_number'     => 'MSSFU2x-uidNumber',
    ldap_user_gid_number'     => 'MSSFU2x-gidNumber',
    ldap_user_home_directory' => 'msSFUHomeDirectory',
    ldap_group_gid_number'    => 'MSSFU2x-gidNumber',
    ...
  },
}
```

### Authenticate against multiple domains
SSSD makes it easy to authenticate against multiple domains. You need to
create a second (or third) `sssd::domain` resource and fill in the
appropriate parameters as shown above.

You also need to add the domain, with the same name, to the array of domains
passed to the sssd class. This defines the lookup order.

```puppet
class { 'sssd':
  domains  => [ 'domain_one.com', 'domain_two.com' ],
  services => ['nss', 'pam'],
}
sssd::domain { 'domain_one.com':
  options => {
    ldap_uri => 'ldap://domain_one.com',
    ...
  },
}
sssd::domain { 'domain_two.com':
  options => {
    ldap_uri => 'ldap://domain_two.com',
    ...
  },
}
```

### Configuring service sections

The sssd::service define type can be used to configure the following sections: 

* [nss] 
* [pam]
* [sudo]
* [autofs]
* [ssh]
* [pac]

By default, the [nss] and [pam] sections are specified through the sections parameter (default value comes from params.pp). The sections parameter is a hash of hashes that gets passed to a create_resource function that creates sssd::service resources (useful when using Hiera, see next section). If you're not using Hiera, you can use the sssd::service define type directly.

Please note that if you're using sssd::service directly for pam or nss, you must set the sections parameters to an empty hash so that you avoid duplicate resource declarations.

```puppet
class { 'sssd':
  domains  => [ 'domain_one.com', ],
  services => ['nss', 'pam'],
  sections => {},
}
# The name of resource should be the section name
sssd::service { 'nss':
  options => {
    'filter_groups'        => 'root',
    'filter_users'         => 'root',
    'reconnection_retries' => '3',
  },
}
sssd::service { 'pam':
  options => {
    'reconnection_retries' => '3',
  },
}
```


### Use Hiera for configuration data
The SSSD module is designed to work with the automatic parameter lookup feature
introduced with Hiera in Puppet 3. If you are using Hiera, you can shorten your
Puppet manifest down to one line:

    include sssd

Then add configuration data into your Hiera data files. If you are using a YAML
backend, your configuration file might look like this.

```yaml
sssd::domains:
- 'mydomain.com'
sssd::services:
- nss
- pam
sssd::sections:
  nss:
    options:
      filter_groups: 'root'
      filter_users: 'root'
      reconnection_retries: '3'
  pam:
    options:
      reconnection_retries: '3'
sssd::backends:
  'mydomain.com':
    options:
      ldap_uri: 'ldap://mydomain.com'
      ldap_search_base: 'DC=mydomain,DC=com'
      krb5_realm: 'MYDOMAIN.COM'
      ldap_default_bind_dn: 'CN=SssdService,DC=mydomain,DC=com'
      ldap_default_authtok: 'My ultra-secret password'
      simple_allow_groups: 'SssdAdmins, DomainAdmins'
```

## Parameters

### Class: sssd

#### `domains`
Required. Array. For each sssd::domain type you declare, you SHOULD also
include the domain name here. This defines the domain lookup order.

#### `services`
Required. Array. Default is ['nss', 'pam']. For each sssd::service type 
you declare, you SHOULD also include the service name here.

#### `options`
Optional. Hash. Default is an empty hash. Key/value pairs will be used to 
set options underneath the [sssd] section in /etc/sssd/sssd.conf.

#### `sections`
Optional. Hash. Default is a hash from sssd::params. The typical way of 
setting up services for SSSD is by using the sssd::service defined type. 
That poses a problem if you want to use Hiera for storing your configuration 
data. This parameter allows you to pass a hash that is used to automatically 
instantiate sssd::service types.

#### `backends`
Optional. Hash. Default is an empty hash. The typical way of setting up 
backends for SSSD is by using the sssd::domain defined type. That poses 
a problem if you want to use Hiera for storing your configuration data. 
This parameter allows you to pass a hash that is used to automatically 
instantiate sssd::domain types.

#### `make_home_dir`
(true|false) Optional. Boolean. Default is false. Enable this if you
want network users to have a home directory created when they login. For now,
this option is only available for RedHat family machines.

#### `packages`
Optional. Default comes from sssd::params based on osfamily fact. 
You can override which packages this module installs with this parameter.
Be sure to use an array if it's more than one package.

#### `manage_cron`
(true|false) Optional. Boolean. Default is true. This parameter will
toggle whether or not this module attempts to restart the cron service
everytime the sssd service is restarted.

### Define Type: sssd::service

#### `options`
Required. Hash. Top-level keys will be used to set [sections] headers in 
/etc/sssd/sssd.conf. The Key/value pairs stemming from these top-level 
keys will be used to set options underneath that section.

#### `sssd_service`
Optional. String. Defaults to using the name parameter. Sets the name for the
service's [header] section. Supported services include: nss, pam, sudo, 
autofs, ssh, pac.

#### `concat order`
Optional. String. Defaults to '30'. This will be passed to the 
concat::fragment resource to set the order attribute.

### Define Type: sssd::domain

#### `options`
Required. Hash. Key/value pairs will be used to set options underneath a 
[domain/name] section in /etc/sssd/sssd.conf.

#### `ldap_domain`
Optional. String. Fully-qualified DNS name of your LDAP domain.
Defaults to using the name parameter.

#### `ldap_tls_cacert`
Optional. String. If desired, you can specify a file containing trusted 
Certificate Authorities. Otherwise, sssd will use the OpenLDAP defaults 
in /etc/openldap/ldap.conf.

#### `concat order`
Optional. String. Defaults to '30'. This will be passed to the 
concat::fragment resource to set the order attribute.

## Development

### Issues

Please submit issues or feature requests for this module [here](https://github.com/sfu-rcg/sssd/issues).

### Versioning

This module uses [Semantic Versioning](http://semver.org/).

### Branching
Please adhere to the branching guidelines set out by Vincent Driessen in this [post](http://nvie.com/posts/a-successful-git-branching-model/).

### Testing
This module uses [puppetlabs_spec_helper](https://github.com/puppetlabs/puppetlabs_spec_helper), and [rspec-puppet](http://rspec-puppet.com) for testing.

Getting started:

```bash
# After a git clone
cd sssd
bundle install
# Run rspec-puppet tests
rake spec
# Validate all files
rake validate
# View list of all available rake taks
rake -T
```

## Special Acknowledgements

Thank you to [Nic Waller](https://github.com/nicwaller) for originally creating this module. And thank you to [Martijn de Gouw](https://github.com/martijndegouw) for his pull request to include Debian support.
