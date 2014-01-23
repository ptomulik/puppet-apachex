class apachex::params::error_log {
  $value = $::osfamily ? {
    'debian'    => '\${APACHE_LOG_DIR}/error.log',
    'freebsd'   => '/var/log/httpd-error.log',
  }
}
