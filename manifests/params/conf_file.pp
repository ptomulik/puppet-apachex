class apachex::params::conf_file {
  $value = $::osfamily ? {
    'archlinux' => 'httpd.conf',
    'debian'    => 'apache2.conf',
    'freebsd'   => 'httpd.conf',
    'redhat'    => 'httpd.conf',
  }
}
