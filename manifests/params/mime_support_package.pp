class apachex::params::mime_support_package {
  $value = $::osfamily ? {
    'archlinux' => undef, # NOTE: mime.types perhaps provided by apache package
    'debian'    => 'mime-support',
    'freebsd'   => 'misc/mime-support',
    'redhat'    => undef, # FIXME: does redhat need package? (mailcap?) 
  }
}
