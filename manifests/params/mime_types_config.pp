class apachex::params::mime_types_config {
  include apachex::params::conf_dir
  $conf_dir = $apachex::params::conf_dir::value
  $value = $::osfamily ? {
    'archlinux' => "${conf_dir}/mime.types",
    'debian'    => '/etc/mime.types',
    'freebsd'   => 'etc/apache22/mime.types',
    'redhat'    => '/etc/mime.types',
  }
}
