class apachex::params::vhost_enable_dir {
  $value = $::osfamily ? {
    'debian' => "${httpd_dir}/sites-enabled",
    default  => undef,
  }
}
