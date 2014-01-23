class apachex::params::group {
  $value = $::osfamily ? {
    'archlinux' => 'http',
    'debian'    => 'www-data',
    'freebsd'   => 'www',
    'redhat'    => 'apache',
  }
}
