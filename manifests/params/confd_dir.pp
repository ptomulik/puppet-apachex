class apachex::params::confd_dir {
  include apachex::params::httpd_dir
  $httpd_dir = $apachex::params::httpd_dir::value
  $value = $::osfamily ? {
    'archlinux' => "${httpd_dir}/conf/extra",
    'debian'    => "${httpd_dir}/conf.d",
    'freebsd'   => confd_dir_debian,
    'redhat'    => "${httpd_dir}/conf.d",
  }
}
