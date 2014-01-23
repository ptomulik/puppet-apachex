class apachex::params::default_ssl_key {
  include apachex::params::conf_dir
  $conf_dir = $apachex::params::conf_dir::value
  $value = $::osfamily ? {
    'archlinux' => "${conf_dir}/server.key",
    'debian'    => '/etc/ssl/certs/ssl-cert-snakeoil.key',
    'freebsd'   => "${conf_dir}/server.key",
    'redhat'    => '/etc/pki/tls/certs/localhost.key',
  }
}
