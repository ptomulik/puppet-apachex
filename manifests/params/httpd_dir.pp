class apachex::params::httpd_dir {
  $value = $::osfamily ? {
    'archlinux' => '/etc/httpd',
    'debian'    => '/etc/apache2',
    'freebsd'   => '/usr/local/etc/apache22',
    'redhat'    => '/etc/httpd',
  }
}
