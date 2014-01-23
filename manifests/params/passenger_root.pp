class apachex::params::passenger_root {
  include apachex::params::passenger_version
  include apachex::params::ruby_version
  $passenger_version = $apachex::params::passenger_version::value
  $ruby_version = $apachex::params::ruby_version::value
  $value = $::osfamily ? {
    'archlinux' => "/usr/share/rubygems/gems/passenger-${passenger_version}",
    'debian'    => '/usr',
    'freebsd'   => "/usr/local/lib/ruby/gems/${ruby_version}/gems/passenger-${passenger_version}",
    'redhat'    => "/usr/share/rubygems/gems/passenger-${passenger_version}",
  }
}
