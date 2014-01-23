class apachex::params::server_root {
  $value = $::osfamily ? {
    'archlinux' => '/etc/httpd',
    'debian'    => '/etc/apache2',
    'freebsd'   => '/usr/local',
    'redhat'    => '/etc/httpd',
  }
}
