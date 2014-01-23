class apachex::params::conf_dir {
  include apachex::params::httpd_dir
  $httpd_dir = $apachex::params::httpd_dir::value
  $value = $::osfamily ? {
    'archlinux' => "${httpd_dir}/conf",
    'debian'    => $httpd_dir,
    'freebsd'   => $httpd_dir,
    'redhat'    => "${httpd_dir}/conf",
  }
}
