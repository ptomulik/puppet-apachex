# == Class: apachex::params
#
# Default settings of apachex class.
#
# === Parameters
#
# None
#
# === Variables
#
# The apachex::params defines following defaults:
#
# [*available_mpms*]
#   MPM modules available on this platform
#
#
# The apachex::params requires following variables:
#
# [*::osfamily*]
#   Fact from facter
#
#
# === Examples
#
#  class apachex ( ... ) inherits mysql::params { ... }
#
# === Authors
#
# Pawel Tomulik <ptomulik@meil.pw.edu.pl>
#
# === Copyright
#
# Copyright 2013-2014 Pawel Tomulik.
#
class apachex::params {

  # please keep this list sorted alphabetically
  include apachex::params::apache_name
  include apachex::params::apache_service
  include apachex::params::apache_version
  include apachex::params::cgi_bin_dir
  include apachex::params::confd_dir
  include apachex::params::conf_dir
  include apachex::params::conf_file
  include apachex::params::conf_template
  include apachex::params::custom_log
  include apachex::params::default_ssl_cert
  include apachex::params::default_ssl_key
  include apachex::params::mime_default_type
  include apachex::params::dev_packages
  include apachex::params::distrelease
  include apachex::params::document_root
  include apachex::params::error_log
  include apachex::params::group
  include apachex::params::httpd_dir
  include apachex::params::keepalive
  include apachex::params::keepalive_timeout
  include apachex::params::lib_path
  include apachex::params::listen
  include apachex::params::log_level
  include apachex::params::logroot
  include apachex::params::mime_support_package
  include apachex::params::mime_types_config
  include apachex::params::mod_dir
  include apachex::params::mod_enable_dir
  include apachex::params::mod_libs
  include apachex::params::mod_packages
  include apachex::params::mpm_module
  include apachex::params::passenger_root
  include apachex::params::passenger_ruby
  include apachex::params::passenger_version
  include apachex::params::ports_file
  include apachex::params::root_group
  include apachex::params::ruby_version
  include apachex::params::servername
  include apachex::params::server_admin
  include apachex::params::server_root
  include apachex::params::ssl_certs_dir
  include apachex::params::suphp_addhandler
  include apachex::params::suphp_configpath
  include apachex::params::suphp_engine
  include apachex::params::user
  include apachex::params::vhost_dir
  include apachex::params::vhost_enable_dir

  # please keep this list sorted alphabetically
  $apache_name          = $apachex::params::apache_name::value
  $apache_service       = $apachex::params::apache_service::value
  $apache_version       = $apachex::params::apache_version::value
  $cgi_bin_dir          = $apachex::params::cgi_bin_dir::value
  $confd_dir            = $apachex::params::confd_dir::value
  $conf_dir             = $apachex::params::conf_dir::value
  $conf_file            = $apachex::params::conf_file::value
  $conf_template        = $apachex::params::conf_template::value
  $custom_log           = $apachex::params::custom_log::value
  $default_ssl_cert     = $apachex::params::default_ssl_cert::value
  $default_ssl_key      = $apachex::params::default_ssl_key::value
  $mime_default_type    = $apachex::params::mime_default_type::value
  $dev_packages         = $apachex::params::dev_packages::value
  $distrelease          = $apachex::params::distrelease::value
  $document_root        = $apachex::params::document_root::value
  $error_log            = $apachex::params::error_log::value
  $group                = $apachex::params::group::value
  $httpd_dir            = $apachex::params::httpd_dir::value
  $keepalive            = $apachex::params::keepalive::value
  $keepalive_timeout    = $apachex::params::keepalive_timeout::value
  $lib_path             = $apachex::params::lib_path::value
  $listen               = $apachex::params::listen::value
  $log_level            = $apachex::params::log_level::value
  $logroot              = $apachex::params::logroot::value
  $mime_support_package = $apachex::params::mime_support_package::value
  $mime_types_config    = $apachex::params::mime_types_config::value
  $mod_dir              = $apachex::params::mod_dir::value
  $mod_enable_dir       = $apachex::params::mod_enable_dir::value
  $mod_libs             = $apachex::params::mod_libs::value
  $mod_packages         = $apachex::params::mod_packages::value
  $mpm_module           = $apachex::params::mpm_module::value
  $passenger_root       = $apachex::params::passenger_root::value
  $passenger_ruby       = $apachex::params::passenger_ruby::value
  $passenger_version    = $apachex::params::passenger_version::value
  $ports_file           = $apachex::params::ports_file::value
  $root_group           = $apachex::params::root_group::value
  $ruby_version         = $apachex::params::ruby_version::value
  $servername           = $apachex::params::servername::value
  $server_admin         = $apachex::params::server_admin::value
  $server_root          = $apachex::params::server_root::value
  $ssl_certs_dir        = $apachex::params::ssl_certs_dir::value
  $suphp_addhandler     = $apachex::params::suphp_addhandler::value
  $suphp_configpath     = $apachex::params::suphp_configpath::value
  $suphp_engine         = $apachex::params::suphp_engine::value
  $user                 = $apachex::params::user::value
  $vhost_dir            = $apachex::params::vhost_dir::value
  $vhost_enable_dir     = $apachex::params::vhost_enable_dir::value
}
