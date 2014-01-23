class apachex::params::apache_service {
  $value = $::osfamily ? {
    'archlinux' => 'httpd',
    'debian'    => 'apache2',
    'freebsd'   => 'apache22',
    'redhat'    => 'httpd',
  }
}
