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
      expect = all_params_absent.clone
      expect['name'] = 'apache2'
      it { should contain_package('apache2').with(expect) }
    end
    context "with $ensure=2.2 and available versions #{repo_versions}" do
      let :params do { 'ensure' => '2.2' } end
      expect = all_params_absent.clone
      expect['name']    = 'apache2'
      expect['ensure']  = '2.2.22-13'
      it { should contain_package('apache2').with(expect) }
    end
    context "with $ensure=2.2, available apache versions #{repo_versions} and apache 2.2.16 already installed" do
      let :params do { 'ensure' => '2.2' } end
      let :facts do
        {
          :osfamily                   => 'Debian',
          :apachex_repo_versions      => "apache2 #{repo_versions}",
          :apachex_installed_version  => 'apache2 2.2.16-6+squeeze10',
        }
      end
      expect = all_params_absent.clone
      expect['name']    = 'apache2'
      expect['ensure']  = 'present'
      it { should contain_package('apache2').with(expect) }
    end
  end
  context "on a FreeBSD OS" do
    let(:facts) do
      {
        :osfamily                   => 'FreeBSD',
        :apachex_repo_versions      => nil,
        :apachex_installed_version  => nil,
      }
    end
    context "with all parameters default" do
      expect = all_params_absent.clone
      expect['name'] = 'www/apache22'
      it { should contain_package('apache2').with(expect) }
    end

    [
      # $ensure, $mpm, $installed, $package_name, $package_ensure
      [  nil,   nil,        'www/apache24 2.4.6',  'www/apache24', nil ],
      ['2.2',   nil,        nil,                   'www/apache22', 'present' ],
      ['2.4',   nil,        nil,                   'www/apache24', 'present' ],
      ['2.4',   nil,        'www/apache24 2.4.6',  'www/apache24', 'present' ],
      ['2.2',   nil,        'www/apache24 2.4.6',  'www/apache22', 'present' ],
      [  nil,   'prefork',  'www/apache22 2.2.13', 'www/apache22', nil ],
      [  nil,   'worker',   'www/apache22 2.2.13', 'www/apache22-worker-mpm', nil ],
      [  nil,   'prefork',  'www/apache24 2.4.6',  'www/apache24', nil ],
      [  nil,   'worker',   'www/apache24 2.4.6',  'www/apache24', nil ],
      ['2.2',   'itk',      'www/apache22-worker-mpm 2.2.13',  'www/apache22-itk-mpm', 'present' ],
    ].each do |args|
      params            = {}
      params['ensure']  = args[0] if not args[0].nil?
      params['mpm']     = args[1] if not args[1].nil?
      installed         = args[2]
      package_name      = args[3]
      package_ensure    = args[4]

      d_ensure    = args[0].nil? ? 'no $ensure' : "$ensure='#{args[0]}'"
      d_mpm       = args[1].nil? ? 'no $mpm' : "$mpm='#{args[1]}'"
      d_installed = installed.nil? ? 'apache not installed' : "'#{installed}' already installed"

      installed_name = installed.nil? ? nil : installed.split(' ')[0]

      context "with #{d_ensure}, #{d_mpm}, and #{d_installed}" do
        let :facts do
          {
            :osfamily                   => 'FreeBSD',
            :apachex_repo_versions      => nil,
            :apachex_installed_version  => installed,
          }
        end
        let :params do params end
        expect = all_params_absent.clone
        expect['name'] = package_name
        expect['ensure'] = package_ensure
        if params['ensure'] != 'absent'
          it {should_not contain_package(package_name).with({'ensure'=>'absent'})}
        end
        if params['ensure'] != 'purged'
          it {should_not contain_package(package_name).with({'ensure'=>'purged'})}
        end
        if installed_name and installed_name != package_name
          it {should contain_package(installed_name).with({'ensure'=>'absent'})}
        end
        it { should contain_package('apache2').with(expect) }
        it { should contain_file_line('APACHE_PORT in /etc/make.conf').with({'line' => "APACHE_PORT=#{package_name}"})}
      end
    end
  end
  context "on a RedHat OS" do
    let(:facts) do
      {
        :osfamily => 'RedHat'
      }
    end
    context "with all parameters default" do
      expect = all_params_absent.clone
      expect['name'] = 'httpd'
      it { should contain_package('apache2').with(expect) }
    end
  end

  context "on any system" do
    context "with $package=apache" do
      let :params do { 'package' => 'apache' } end
      expect = all_params_absent.clone
      expect['name'] = 'apache'
      it { should contain_package('apache2').with(expect) }
    end
  end
end
