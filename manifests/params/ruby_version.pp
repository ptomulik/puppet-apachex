class apachex::params::ruby_version {
  # NOTE: shouldn't this be sent via facts?
  # TODO: revisit this file
  $value = $::osfamily ? {
    'archlinux' => '1.9',
    'debian'    => '1.9.1',
    'freebsd'   => '1.9',
    'redhat'    => '1.9',
  }
}
