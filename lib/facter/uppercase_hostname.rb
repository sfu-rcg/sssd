require 'puppet'

# Sometimes needed for ldap_sasl_authid
Facter.add("uppercase_hostname") do
  setcode do
    hostname = Facter.value(:hostname)
    hostname.upcase rescue(nil)
  end
end
