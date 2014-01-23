class apachex::params::document_root {
  $value = $::osfamily ? {
    'debian'    => '/var/www',
    'freebsd'   => '/usr/local/www/apache22/data',
  }
}
