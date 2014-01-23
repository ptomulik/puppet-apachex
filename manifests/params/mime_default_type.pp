class apachex::params::mime_default_type{
  $value = $::osfamily ? {
    'debian'    => 'text/plain',
    'freebsd'   => 'text/plain',
  }
}
