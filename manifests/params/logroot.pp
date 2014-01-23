class apachex::params::logroot {
  $value = $::osfamily ? {
    'archlinux' => '/var/log/httpd',
    'debian'    => '/var/log/apache2',
    'freebsd'   => '/var/log/apache22',
    'redhat'    => '/var/log/httpd',
  }
}
