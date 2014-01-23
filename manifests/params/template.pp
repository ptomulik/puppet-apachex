class apachex::params::xxx {
  $value = $::osfamily ? {
    'archlinux' => xxx_archlinux,
    'debian'    => xxx_debian,
    'freebsd'   => xxx_freebsd,
    'redhat'    => xxx_redhat,
  }
}
