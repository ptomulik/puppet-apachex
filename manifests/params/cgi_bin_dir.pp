class apachex::params::cgi_bin_dir {
  $value = $::osfamily ? {
    'debian'    => '/usr/lib/cgi-bin',
    'freebsd'   => '/usr/local/www/apache22/cgi-bin',
  }
}
