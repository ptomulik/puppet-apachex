class apachex::params::user {
  $value = $::osfamily ? {
    'archlinux' => 'http',
    'debian'    => 'www-data',
    'freebsd'   => 'www',
    'redhat'    => 'apache',
  }
}
