# == Define: apachex::instance
#
# Apache server instance.
#
# === Parameters
#
# Document parameters here.
#
# [*instance_name*]
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  TODO: provide usage example(s)
#  class { 'apachex::instance'
#   ...
#  }
#
# === Authors
#
# Pawel Tomulik <ptomulik@meil.pw.edu.pl>
#
# === Copyright
#
# Copyright 2013 Pawel Tomulik, unless otherwise noted.
#
define apachex::instance (
  $conf_dir = undef,
  $instance_name = $name,
){
  validate_re($instance_name, '^[a-zA-Z][a-zA-Z0-9_]+$')


  if !$conf_dir {
    $base_dir = $::osfamily ? {
      'FreBSD' => 'Instances',
      default  => 'instances',
    }
    $instance_conf_dir = "${apache::conf_dir}/${base_dir}/${instance_name}"
  } else {
    $instance_conf_dir = $conf_dir
  }
}
