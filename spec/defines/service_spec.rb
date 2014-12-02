require 'spec_helper'

describe 'sssd::service', :type => :define do
  context "with a options => unset" do
    let :title do
      'nss'
    end
    it { expect { should compile }.to raise_error(/Must pass options/) }
  end
  
  context "with a name => not_matched, options => set" do
    let :title do
      'notamatch'
    end
    let :params do
      {
        :options => {'key' => 'value'},
      }
    end
    it { expect { should compile }.to raise_error(/does not match a supported service/) }
  end
  
  context "with a options => string" do
    let :title do
      'nss'
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
      'nss'
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
        domains  => [ 'mydomain.com' ],
        sections => {},
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
        'nss'
      end
      let :params do
        {
          :options      => {'key' => 'value'},
        }
      end
      it do
        should compile.with_all_deps
        should contain_concat__fragment('sssd_service_nss').with(
        'target'  => 'sssd_conf',
        #'content' => 'template(sssd/domain_sssd.conf.erb)',
        'order'   => '20',
        )
      end
    end
    
    context "with a options => set, concat_order => set" do
      let :title do
        'nss'
      end
      let :params do
        {
          :options         => {'key' => 'value'},
          :concat_order    => '15'
        }
      end
      it do
        should compile.with_all_deps
        should contain_concat__fragment('sssd_service_nss').with(
        'target'  => 'sssd_conf',
        #'content' => 'template(sssd/domain_sssd.conf.erb)',
        'order'   => '15',
        )
      end
    end
  end
  
  context "on a Debian system" do
    let :pre_condition do
      "class { 'sssd':
      domains  => [ 'mydomain.com' ],
      sections => {},
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
        'nss'
      end
      let :params do
        {
          :options      => {'key' => 'value'},
        }
      end
      it do
        should compile.with_all_deps
        should contain_concat__fragment('sssd_service_nss').with(
        'target'  => 'sssd_conf',
        #'content' => 'template(sssd/domain_sssd.conf.erb)',
        'order'   => '20',
        )
      end
    end
    
    context "with a options => set, concat_order => set" do
      let :title do
        'nss'
      end
      let :params do
        {
          :options         => {'key' => 'value'},
          :concat_order    => '15'
        }
      end
      it do
        should compile.with_all_deps
        should contain_concat__fragment('sssd_service_nss').with(
        'target'  => 'sssd_conf',
        #'content' => 'template(sssd/domain_sssd.conf.erb)',
        'order'   => '15',
        )
      end
    end

  end
end
