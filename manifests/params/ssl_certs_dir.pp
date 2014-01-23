class apachex::params::ssl_certs_dir {
  include apachex::params::distrelease
  include apachex::params::httpd_dir
  $distrelease = $apachex::params::distrelease::value
  $httpd_dir = $apachex::params::httpd_dir::value
  $value = $::osfamily ? {
    'archlinux' => '/etc/ssl/certs',
    'debian'    => '/etc/ssl/certs',
    'freebsd'   => $httpd_dir,
    'redhat'    => $distrelease ? {
      '5'     => '/etc/pki/tls/certs',
      default => '/etc/ssl/certs',
    }
  }
}
