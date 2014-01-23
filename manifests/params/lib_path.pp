class apachex::params::lib_path {
  $value = $::osfamily ? {
    'archlinux' => '/usr/lib/httpd/modules',
    'debian'    => '/usr/lib/apache2/modules',
    'freebsd'   => '/usr/local/libexec/apache22',
    'redhat'    => 'modules',
  }
}
