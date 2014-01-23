class apachex::params::passenger_version {
  # NOTE: shouldn't this be sent via facts?
  $value = $::osfamily ? {
    'archlinux' => '3.0.17',
    'debian'    => undef,
    'freebsd'   => '4.0.10',
    'redhat'    => '3.0.17',
  }
}
