class apachex::params::custom_log {
  $value = $::osfamily ? {
    'debian'    => ['\${APACHE_LOG_DIR}/access.log','combined'],
    'freebsd'   => ['/var/log/httpd-access.log','combined'],
  }
}
