# == Class: apachex::params
#
# Default settings of apachex class.
#
# === Parameters
#
# None
#
# === Variables
#
# The apachex::params defines following defaults:
#
# [*available_mpms*]
#   MPM modules available on this platform
#
#
# The apachex::params requires following variables:
#
# [*::osfamily*]
#   Fact from facter
#
#
# === Examples
#
#  class apachex ( ... ) inherits mysql::params { ... }
#
# === Authors
#
# Pawel Tomulik <ptomulik@meil.pw.edu.pl>
#
# === Copyright
#
# Copyright 2013 Pawel Tomulik.
#
class apachex::params {
}
