class apachex::params::mpm_module {
  $value = $::osfamily ? {
    'archlinux' => 'worker',
    'debian'    => 'worker',
    'freebsd'   => 'prefork',
    'redhat'    => 'prefork',
  }
}
