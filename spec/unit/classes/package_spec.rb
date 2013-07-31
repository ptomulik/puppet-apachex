require 'spec_helper'

describe 'apachex::package', :type => :class do
  let :pre_condition do
    'class {\'apachex\': include_package => false}'
  end
  all_params_absent = {
          'adminfile'         => nil,
          'allowcdrom'        => nil,
          'configfiles'       => nil,
          'ensure'            => nil,
          'flavor'            => nil,
          'install_options'   => nil,
          'name'              => nil,
          'responsefile'      => nil,
          'root'              => nil,
          'source'            => nil,
          'uninstall_options' => nil,
  }
  context "on a Debian OS" do
    repo_versions = '2.2.16-6+squeeze10 2.2.22-13 2.4.6-2'
    let :facts do
      {
        :osfamily                   => 'Debian',
        :apachex_repo_versions      => "apache2 #{repo_versions}",
        :apachex_installed_version  => nil,
      }
    end
    context "with all parameters default" do
      params = all_params_absent.clone
      params['name'] = 'apache2'
      it { should contain_package('apache2').with(params) }
    end
    context "with $ensure=2.2 and available versions #{repo_versions}" do
      let :params do { 'ensure' => '2.2' } end
      params = all_params_absent.clone
      params['name']    = 'apache2'
      params['ensure']  = '2.2.22-13'
      it { should contain_package('apache2').with(params) }
    end
    context "with $ensure=2.2, available versions #{repo_versions} but apache v. 2.2.16 already installed" do
      let :params do { 'ensure' => '2.2' } end
      let :facts do
        {
          :osfamily                   => 'Debian',
          :apachex_repo_versions      => "apache2 #{repo_versions}",
          :apachex_installed_version  => 'apache2 2.2.16-6+squeeze10',
        }
      end
      params = all_params_absent.clone
      params['name']    = 'apache2'
      params['ensure']  = 'present'
      it { should contain_package('apache2').with(params) }
    end
  end
  context "on a FreeBSD OS" do
    let(:facts) do
      {
        :osfamily => 'FreeBSD'
      }
    end
    context "with all parameters default" do
      params = all_params_absent.clone
      params['name'] = 'www/apache22'
      it { should contain_package('apache2').with(params) }
    end
    # TODO: much more test for FreeBSD
  end
  context "on a RedHat OS" do
    let(:facts) do
      {
        :osfamily => 'RedHat'
      }
    end
    context "with all parameters default" do
      params = all_params_absent.clone
      params['name'] = 'httpd'
      it { should contain_package('apache2').with(params) }
    end
  end

  context "on any system" do
    context "with $package=apache" do
      let :params do { 'package' => 'apache' } end
      params = all_params_absent.clone
      params['name'] = 'apache'
      it { should contain_package('apache2').with(params) }
    end
  end
end
