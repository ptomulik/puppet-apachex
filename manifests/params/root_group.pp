class apachex::params::root_group {
  $value = $::osfamily ? {
    'archlinux' => 'root',
    'debian'    => 'root',
    'freebsd'   => 'wheel',
    'redhat'    => 'root',
  }
}
