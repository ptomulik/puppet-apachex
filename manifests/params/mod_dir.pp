class apachex::params::mod_dir {
  include apachex::params::httpd_dir
  $httpd_dir = $apachex::params::httpd_dir::value
  $value = $::osfamily ? {
    'archlinux' => "${httpd_dir}/modules",
    'debian'    => "${httpd_dir}/mods-available",
    'freebsd'   => "${httpd_dir}/modules.d",
    'redhat'    => "${httpd_dir}/conf.d",
  }
}
