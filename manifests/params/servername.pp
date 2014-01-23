class apachex::params::servername {
  if($::fqdn) {
    $value = $::fqdn
  } else {
    $value = $::hostname
  }
}
