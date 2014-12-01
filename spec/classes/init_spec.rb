require 'spec_helper'
describe 'sssd', :type => 'class' do
  
  context 'on an unsupported system' do
    let :facts do
      {
        :osfamily       => 'notsupported',
      }
    end
    
    context 'with domains => set' do
      let :params do
        {
          :domains => ['mydomain.com'],
        }
      end
      it { expect { should compile }.to raise_error(/Unsupported distribution/) }
    end
    
  end
  
  context 'on a RedHat system' do
    let :facts do
      {
        :osfamily       => 'RedHat',
        :concat_basedir => '/dne',
      }
    end

    context 'with domains => unset' do
      it { expect { should compile }.to raise_error(/Must pass domains/) }
    end
    
    context 'with domains => string' do
      let :params do
        {
          :domains => 'string',
        }
      end
      it { expect { should compile }.to raise_error(/not an Array/) }
    end
    
    context 'with services => string' do
      let :params do
        {
          :domains => 'string',
        }
      end
      it { expect { should compile }.to raise_error(/not an Array/) }
    end
    
    context 'with options => string' do
      let :params do
        {
          :domains => ['value'],
          :options => 'string'
        }
      end
      it { expect { should compile }.to raise_error(/not a Hash/) }
    end
    
    context 'with sections => string' do
      let :params do
        {
          :domains  => ['value'],
          :options  => {'key' => 'value'},
          :sections => 'string',
        }
      end
      it { expect { should compile }.to raise_error(/not a Hash/) }
    end
    
    context 'with backends => string' do
      let :params do
        {
          :domains  => ['value'],
          :backends => 'string'
        }
      end
      it { expect { should compile }.to raise_error(/not a Hash/) }
    end
    
    context 'with make_home_dir => string' do
      let :params do
        {
          :domains       => ['value'],
          :make_home_dir => 'string'
          
        }
      end
      it { expect { should compile }.to raise_error(/is not a boolean/) }
    end
    
    context 'with domains => set, sections => default' do
      let :params do
        {
          :domains       => [ 'mydomain.com' ],
        }
      end
      it do
        should compile.with_all_deps
        contain_package('sssd').with_ensure('installed')
        should contain_concat('sssd_conf').with(
          'path' => '/etc/sssd/sssd.conf',
          'mode' => '0600',
        )
        should contain_concat__fragment('sssd_conf_header').with(
          'target'  => 'sssd_conf',
          #'content' => 'template(sssd/header_sssd.conf.erb)',
          'order'   => '10',
        )
        should contain_exec('authconfig-sssd').with_command('/usr/sbin/authconfig --enablesssd --enablesssdauth --enablelocauthorize --update')
        should contain_service('sssd').with(
          'ensure' => 'running',
          'enable' => 'true',
        ).that_subscribes_to('Exec[authconfig-sssd]')
        should contain_service('crond').that_subscribes_to('Service[sssd]')
      end
    end
    
    context 'with domains => set, sections => default, make_home_dir => true' do
      let :params do
        {
          :domains       => [ 'mydomain.com' ],
          :make_home_dir => true,
        }
      end
      it do
        should compile.with_all_deps
        should contain_class('sssd::homedir')
        contain_package('sssd').with_ensure('installed')
        should contain_concat('sssd_conf').with(
        'path' => '/etc/sssd/sssd.conf',
        'mode' => '0600',
        )
        should contain_concat__fragment('sssd_conf_header').with(
        'target'  => 'sssd_conf',
        #'content' => 'template(sssd/header_sssd.conf.erb)',
        'order'   => '10',
        )
        should contain_exec('authconfig-sssd').with_command('/usr/sbin/authconfig --enablesssd --enablesssdauth --enablelocauthorize --update')
        should contain_service('sssd').with(
        'ensure' => 'running',
        'enable' => 'true',
        ).that_subscribes_to('Exec[authconfig-sssd]')
        should contain_service('crond').that_subscribes_to('Service[sssd]')
      end
    end
    
  end
end
