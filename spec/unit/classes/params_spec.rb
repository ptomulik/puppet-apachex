require 'spec_helper'

describe 'apachex::params', :type => :class do
  context "On a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
      }
    end
    #it { should contain_apache__defaults }

    # please, keep it sorted alphabetically
    it { should contain_class('apachex::params::apache_name') }
    it { should contain_class('apachex::params::apache_service') }
    it { should contain_class('apachex::params::apache_version') }
    it { should contain_class('apachex::params::cgi_bin_dir') }
    it { should contain_class('apachex::params::confd_dir') }
    it { should contain_class('apachex::params::conf_dir') }
    it { should contain_class('apachex::params::conf_file') }
    it { should contain_class('apachex::params::conf_template') }
    it { should contain_class('apachex::params::default_ssl_cert') }
    it { should contain_class('apachex::params::default_ssl_key') }
    it { should contain_class('apachex::params::dev_packages') }
    it { should contain_class('apachex::params::distrelease') }
    it { should contain_class('apachex::params::document_root') }
    it { should contain_class('apachex::params::error_log') }
    it { should contain_class('apachex::params::group') }
    it { should contain_class('apachex::params::httpd_dir') }
    it { should contain_class('apachex::params::keepalive') }
    it { should contain_class('apachex::params::keepalive_timeout') }
    it { should contain_class('apachex::params::lib_path') }
    it { should contain_class('apachex::params::listen') }
    it { should contain_class('apachex::params::log_level') }
    it { should contain_class('apachex::params::logroot') }
    it { should contain_class('apachex::params::mime_default_type') }
    it { should contain_class('apachex::params::mime_support_package') }
    it { should contain_class('apachex::params::mime_types_config') }
    it { should contain_class('apachex::params::mod_dir') }
    it { should contain_class('apachex::params::mod_enable_dir') }
    it { should contain_class('apachex::params::mod_libs') }
    it { should contain_class('apachex::params::mod_packages') }
    it { should contain_class('apachex::params::mpm_module') }
    it { should contain_class('apachex::params::passenger_root') }
    it { should contain_class('apachex::params::passenger_ruby') }
    it { should contain_class('apachex::params::passenger_version') }
    it { should contain_class('apachex::params::ports_file') }
    it { should contain_class('apachex::params::root_group') }
    it { should contain_class('apachex::params::ruby_version') }
    it { should contain_class('apachex::params::servername') }
    it { should contain_class('apachex::params::server_admin') }
    it { should contain_class('apachex::params::server_root') }
    it { should contain_class('apachex::params::ssl_certs_dir') }
    it { should contain_class('apachex::params::suphp_addhandler') }
    it { should contain_class('apachex::params::suphp_configpath') }
    it { should contain_class('apachex::params::suphp_engine') }
    it { should contain_class('apachex::params::user') }
    it { should contain_class('apachex::params::vhost_dir') }
    it { should contain_class('apachex::params::vhost_enable_dir') }

    # There are 4 + N resources in this class currently (N = number of params)
    # there should not be any more resources because it is a params class
    # The resources are class[apache::defaults], class[main], class[settings], stage[main]
    it "Should not contain any resources" do
      subject.resources.size.should == 51
    end
  end
end
