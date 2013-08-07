# == Class: apachex
#
# Full description of class apachex here.
#
# === Parameters
#
# Document parameters here.
#
# [*available_mpms*]
#   Array of all MPMs available as installable packages on given platform.
#   Default: +$apachex::params::available_mpms+
#
# [*include_package*]
#   Whether to automatically include the +apachex::package+ class with all
#   settings default. Defaults to +true+ (include). If you want to customize
#   package settings, you must set this parameter to +false+ and then define
#   +apachex::package+ manually (see examples below).
#
#     
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*apachex::params::available_mpms*]
#   Used as default value for +$available_mpms+
#
# === Examples
#
# Use apache class with all settings default.
#
#   include apachex
#
# Customize apache package installation
#
#   class { 'apachex': 'include_package' => false }
#   class { 'apachex::package': ensure   => '2.2' }
#
# === Authors
#
# Pawel Tomulik <ptomulik@meil.pw.edu.pl>
#
# === Copyright
#
# Copyright 2013 Pawel Tomulik.
#
class apachex (
  $include_package  = true,
) inherits apachex::params {
  if $include_package {
    include apachex::package
  }
  Class['apachex::package'] -> Class['apachex']


  file {'/tmp/test2':
    ensure  => 'file',
    content => "actual_name: ${apachex::package::actual_name}\nactual_version: ${apachex::package::actual_version}\n",
  }
}
