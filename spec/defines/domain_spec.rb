require 'spec_helper'

describe 'sssd::domain', :type => :define do
  context "with a options => unset" do
    let :title do
      'default'
    end
    it { expect { should compile }.to raise_error(/Must pass options/) }
  end
  
  context "with a options => string" do
    let :title do
      'default'
    end
    let :params do
      {
        :options => 'string',
      }
    end
    it { expect { should compile }.to raise_error(/not a Hash/) }
  end
  
  context "with a options => set, concat_order => boolean" do
    let :title do
      'default'
    end
    let :params do
      {
        :options      => {'key' => 'value'},
        :concat_order => true,
      }
    end
      it { expect { should compile }.to raise_error(/not a string/) }
  end
  
  context "on a RedHat system" do
    let :pre_condition do
      "class { 'sssd':
        domains => [ 'mydomain.com' ],
      }"
    end
    let :facts do
      {
        :osfamily       => 'RedHat',
        :concat_basedir => '/dne',
      }
    end
    
    context "with a options => set" do
      let :title do
        'default'
      end
      let :params do
        {
          :options      => {'key' => 'value'},
        }
      end
      it do
        should compile.with_all_deps
        should contain_concat__fragment('sssd_domain_default').with(
        'target'  => 'sssd_conf',
        #'content' => 'template(sssd/domain_sssd.conf.erb)',
        'order'   => '30',
        )
      end
    end
    
    context "with a options => set, concat_order => set" do
      let :title do
        'default'
      end
      let :params do
        {
          :options      => {'key' => 'value'},
          :concat_order => '35',
        }
      end
      it do
        should compile.with_all_deps
        should contain_concat__fragment('sssd_domain_default').with(
        'target'  => 'sssd_conf',
        #'content' => 'template(sssd/domain_sssd.conf.erb)',
        'order'   => '35',
        )
      end
    end
    
    context "with a options => set, ldap_tls_cacert => set" do
      let :title do
        'default'
      end
      let :params do
        {
          :options         => {'key' => 'value'},
          :ldap_tls_cacert => <<-EOF
-----BEGIN CERTIFICATE-----
XPID7jCCAtYCCQCOcpxKX9Q//DANBgkqhkiG9w0BAQUFADCBuDELMAkGA1UEBhMC
Q0ExGTAXBgNVBAgTEEJyaXRpc2ggQ29sdW1iaWExEjAQBgNVBAcTCVZhbmNvdXZl
cjEXMBUGA1UEChMOUGxhbmV0IEX4cHJlc3MxEzARBgNVBAsTCkRlbGl2ZXJpZXMx
IjAgBgNVBAMTGXRoZXByb2Zlc3Nvci5sb2NhbGhvc3QuY2ExKDAmBgkqhkiG9w0B
CQEWGXRoZXByb2Zlc3NvckBsb2NhbGhvc3QuY2EwHhcNMTQxMTIzMjAyODI4WhcN
MTUxMTIzMjAyODI4WjCBuDELMAkGA1UEBhMCQ0ExGTAXBgNVBAgTEEJyaXRpc2gg
Q29sdW1iaWExEjAQBgNVBAcTCVPhbmNvdXZlcjEXMBUGA1UEChMOUGxhbmV0IEV4
cHJlc3MxEzARBgNVBAsTCkRlbGl2ZXJpZXMxIjAgBgNVBAMTGXRoZXByb2Zlc3Nv
ci5sb2NhbGhvc3QuY2ExKDAmBgkqhkiG9w0BCQEWGXRoZXByb2Zlc3NvckBsb2Nh
bGhvc3QuY2TwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDkhUTmMPhK
3BWVeyRfKRo/D2gniQKW8YsGeMcdD/9Hxw7zaCOD4A46YDyrB8lmfxQD7U9Cd6dS
Dx0embCe5EWHD6WF4t+gQuS6UQqR6P7OVJAGDgBTEtf8V83ViD/G11BP6NVS10wH
hn3S3WwG7hfMWjDQDgY+A1J3eYX6Z/DJ4N14XT8GlsI/RZ3hPDs+T837Vg99qgLH
dlpjeSD7oOK2DNYuto/KsbmZk+NcGK32QvnkVfqO4NSR3jNqpv6MrX3yA5QsxUtL
8dSxi7IpO1hBDsitetNeUyEObIXkseD8/qA1DVyLavYpe/ZJD0/YFhX02gtiISG1
Ci8dwb/F4uJ9AgMBQQEwDQYJKoZIhvcNAQEFBQADggEBACIMjxRh49b7Y/XMmkNf
4Jvv28RRO+dYA1F/przYC8NMDX+da2d4jRzCTlZzTqAthbJs9miVGHmyDr5Vy0fL
PNmvaUriGq8igxn+vjQiw+f3sxxcaY21nmiOva3Z+Bz98Y7+RGVlvkYvf03g7NAx
N9UjAF33sdSDbpNB54hkOh9L9XKrM2GXohJZExQvQc1TECkaAV1ldaV8njtPc1PA
vWK2Ggz9LbCfgJyI6i2nWfLNixClkSzFQf8O50jjsN6d6sWkXtnPlH+NkQmqdO9z
fJCpNXW7YeuTIDjA5vDnHbjSu7p6HdaDV9vU/RxTHVQmYTCGUwgHTOgSKvsFGp1Q
PBC=
-----END CERTIFICATE-----
EOF
        }
      end
      it do
        should compile.with_all_deps
        should contain_file('/etc/sssd/cacerts').with(
          'ensure' => 'directory',
          'mode'   => '0500',
        )
        should contain_file('/etc/sssd/cacerts/default').with(
          'ensure'  => 'present',
          #'content' => $ldap_tls_cacert,
          'mode'    => '0400',
        ).that_comes_before('Concat::Fragment[sssd_domain_default]')
        should contain_concat__fragment('sssd_domain_default').with(
        'target'  => 'sssd_conf',
        #'content' => 'template(sssd/domain_sssd.conf.erb)',
        'order'   => '30',
        )
      end
    end
  end
  
  context "on a Debian system" do
    let :pre_condition do
      "class { 'sssd':
      domains => [ 'mydomain.com' ],
      }"
    end
    let :facts do
      {
        :osfamily       => 'Debian',
        :concat_basedir => '/dne',
      }
    end
    
    context "with a options => set" do
      let :title do
        'default'
      end
      let :params do
        {
          :options      => {'key' => 'value'},
        }
      end
      it do
        should compile.with_all_deps
        should contain_concat__fragment('sssd_domain_default').with(
        'target'  => 'sssd_conf',
        #'content' => 'template(sssd/domain_sssd.conf.erb)',
        'order'   => '30',
        )
      end
    end
    
    context "with a options => set, concat_order => set" do
      let :title do
        'default'
      end
      let :params do
        {
          :options      => {'key' => 'value'},
          :concat_order => '35',
        }
      end
      it do
        should compile.with_all_deps
        should contain_concat__fragment('sssd_domain_default').with(
        'target'  => 'sssd_conf',
        #'content' => 'template(sssd/domain_sssd.conf.erb)',
        'order'   => '35',
        )
      end
    end
    
    context "with a options => set, ldap_tls_cacert => set" do
      let :title do
        'default'
      end
      let :params do
        {
          :options         => {'key' => 'value'},
          :ldap_tls_cacert => <<-EOF
-----BEGIN CERTIFICATE-----
XPID7jCCAtYCCQCOcpxKX9Q//DANBgkqhkiG9w0BAQUFADCBuDELMAkGA1UEBhMC
Q0ExGTAXBgNVBAgTEEJyaXRpc2ggQ29sdW1iaWExEjAQBgNVBAcTCVZhbmNvdXZl
cjEXMBUGA1UEChMOUGxhbmV0IEX4cHJlc3MxEzARBgNVBAsTCkRlbGl2ZXJpZXMx
IjAgBgNVBAMTGXRoZXByb2Zlc3Nvci5sb2NhbGhvc3QuY2ExKDAmBgkqhkiG9w0B
CQEWGXRoZXByb2Zlc3NvckBsb2NhbGhvc3QuY2EwHhcNMTQxMTIzMjAyODI4WhcN
MTUxMTIzMjAyODI4WjCBuDELMAkGA1UEBhMCQ0ExGTAXBgNVBAgTEEJyaXRpc2gg
Q29sdW1iaWExEjAQBgNVBAcTCVPhbmNvdXZlcjEXMBUGA1UEChMOUGxhbmV0IEV4
cHJlc3MxEzARBgNVBAsTCkRlbGl2ZXJpZXMxIjAgBgNVBAMTGXRoZXByb2Zlc3Nv
ci5sb2NhbGhvc3QuY2ExKDAmBgkqhkiG9w0BCQEWGXRoZXByb2Zlc3NvckBsb2Nh
bGhvc3QuY2TwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDkhUTmMPhK
3BWVeyRfKRo/D2gniQKW8YsGeMcdD/9Hxw7zaCOD4A46YDyrB8lmfxQD7U9Cd6dS
Dx0embCe5EWHD6WF4t+gQuS6UQqR6P7OVJAGDgBTEtf8V83ViD/G11BP6NVS10wH
hn3S3WwG7hfMWjDQDgY+A1J3eYX6Z/DJ4N14XT8GlsI/RZ3hPDs+T837Vg99qgLH
dlpjeSD7oOK2DNYuto/KsbmZk+NcGK32QvnkVfqO4NSR3jNqpv6MrX3yA5QsxUtL
8dSxi7IpO1hBDsitetNeUyEObIXkseD8/qA1DVyLavYpe/ZJD0/YFhX02gtiISG1
Ci8dwb/F4uJ9AgMBQQEwDQYJKoZIhvcNAQEFBQADggEBACIMjxRh49b7Y/XMmkNf
4Jvv28RRO+dYA1F/przYC8NMDX+da2d4jRzCTlZzTqAthbJs9miVGHmyDr5Vy0fL
PNmvaUriGq8igxn+vjQiw+f3sxxcaY21nmiOva3Z+Bz98Y7+RGVlvkYvf03g7NAx
N9UjAF33sdSDbpNB54hkOh9L9XKrM2GXohJZExQvQc1TECkaAV1ldaV8njtPc1PA
vWK2Ggz9LbCfgJyI6i2nWfLNixClkSzFQf8O50jjsN6d6sWkXtnPlH+NkQmqdO9z
fJCpNXW7YeuTIDjA5vDnHbjSu7p6HdaDV9vU/RxTHVQmYTCGUwgHTOgSKvsFGp1Q
PBC=
-----END CERTIFICATE-----
EOF
        }
      end
      it do
        should compile.with_all_deps
        should contain_file('/etc/sssd/cacerts').with(
        'ensure' => 'directory',
        'mode'   => '0500',
        )
        should contain_file('/etc/sssd/cacerts/default').with(
        'ensure'  => 'present',
        #'content' => $ldap_tls_cacert,
        'mode'    => '0400',
        ).that_comes_before('Concat::Fragment[sssd_domain_default]')
        should contain_concat__fragment('sssd_domain_default').with(
        'target'  => 'sssd_conf',
        #'content' => 'template(sssd/domain_sssd.conf.erb)',
        'order'   => '30',
        )
      end
    end

  end  
end
