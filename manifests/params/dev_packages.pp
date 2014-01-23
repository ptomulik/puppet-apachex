class apachex::params::dev_packages {
  $value = $::osfamily ? {
    'archlinux' => undef,
    'debian'    => ['libaprutil1-dev', 'libapr1-dev', 'apache2-prefork-dev'],
    'freebsd'   => undef,
    'redhat'    => 'httpd-devel',
  }
}
