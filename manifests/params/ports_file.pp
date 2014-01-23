class apachex::params::ports_file {
  include apachex::params::conf_dir
  include apachex::params::httpd_dir
  $conf_dir = $apachex::params::conf_dir::value
  $httpd_dir = $apachex::params::httpd_dir::value
  $value = $::osfamily ? {
    'archlinux' => "${httpd_dir}/ports.conf", # NOTE: looks quite dtrange ..
    'debian'    => "${conf_dir}/ports.conf",
    'freebsd'   => "${conf_dir}/ports.conf",
    'redhat'    => "${conf_dir}/ports.conf",
  }
}
