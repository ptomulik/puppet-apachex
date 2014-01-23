class apachex::params::suphp_addhandler {
  $value = $::osfamily ? {
    'archlinux' => 'x-httpd-php',
    'debian'    => 'x-httpd-php',
    'freebsd'   => 'x-httpd-php',
    'redhat'    => 'php5-script',
  }
}
