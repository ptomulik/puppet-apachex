class apachex::params::mod_enable_dir {
  $value = $::osfamily ? {
    'archlinux' => undef,
    'debian'    => "${httpd_dir}/mods-enabled",
    'freebsd'   => undef,
    'redhat'    => undef,
  }
}
