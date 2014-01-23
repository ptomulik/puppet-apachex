class apachex::params::vhost_dir {
  include apachex::params::httpd_dir
  $httpd_dir = $apachex::params::httpd_dir::value
  $value = $::osfamily ? {
    'archlinux' => "${httpd_dir}/conf/extra",
    'debian'    => "${httpd_dir}/sites-available",
    'freebsd'   => "${httpd_dir}/Vhosts",
    'redhat'    => "${httpd_dir}/conf.d",
  }
}
