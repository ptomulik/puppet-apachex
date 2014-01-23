class apachex::params::default_ssl_cert {
  include apachex::params::conf_dir
  $conf_dir = $apachex::params::conf_dir::value
  $value = $::osfamily ? {
    'archlinux' => "${conf_dir}/server.crt",
    'debian'    => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
    'freebsd'   => "${conf_dir}/server.crt",
    'redhat'    => '/etc/pki/tls/certs/localhost.crt',
  }
}
