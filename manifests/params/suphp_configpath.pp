class apachex::params::suphp_configpath {
  $value = $::osfamily ? {
    'archlinux' => '/etc/php',
    'debian'    => '/etc/php5/apache2',
    'freebsd'   => undef,
    'redhat'    => undef,
  }
}
