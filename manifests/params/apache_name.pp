class apachex::params::apache_name {
  $value = $::osfamily ? {
    'archlinux' => 'httpd',
    'debian'    => 'apache2',
    'freebsd'   => 'apache22',
    'redhat'    => 'httpd',
  }
}
