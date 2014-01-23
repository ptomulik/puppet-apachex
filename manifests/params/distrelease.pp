class apachex::params::distrelease {
  $osr_array = split($::operatingsystemrelease,'[\/\.]')                        
  $distrelease = $osr_array[0]
  if ! $distrelease {                                                           
  fail("Class['apachex::params::distrelease']: Unparsable \$::operatingsystemrelease: ${::operatingsystemrelease}")
  }                                                                             
}
