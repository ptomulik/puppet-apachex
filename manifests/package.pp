# == Class: apachex::package
#
# This class represents apache package to install on the target OS.
#
# === Parameters
#
# Most parameters are passed directly to the
# package[http://docs.puppetlabs.com/references/latest/type.html#package]i
# resource, so they have exactly same meaning as for the package resource.
# Defaults set by +Package { foo => bar }+ are fully honored. Here we mention
# only the affected package's parameters and new parameters introduced
# by +apachex::package+
#
#   [*ensure*]
#     This has merely same effect as the *ensure* parameter to the +package+
#     resource. The difference here is an enhanced versioning. If you pass
#     "two-digit" version number (+2.2+ for example), it shall still work, even
#     if the underlying +package+'s provider is not versionable. Exact version
#     numbers (for example +2.4.6-2+) are supported only by versionable
#     providers.
#
#     If you pass +2.X+ style version number to fully versionable
#     +apachex::package+, it will install most recent +2.X+ apache package
#     available in repositories. In case the apache package is already
#     installed, the installation (+$ensure => '2.X'+) is triggered only if the
#     installed version does not match the version in +$ensure+. For example,
#     if +$ensure == '2.4'+ and the installed version is +2.4.6-2+, no upgrade
#     will be triggered, even if there is newer version in package repository.
#     The upgrade (reinstall) will be triggered, however, if +$ensure == '2.4'+
#     and the installed version is, for example, +2.2.22-13+.
#
#     Note, that on some systems, migrations between '2.X' and '2.Y' would
#     fail. For example, packages providing apache modules may depend on
#     particular (installed) version of apache. Some package managers are not
#     smart enough to handle the changes in dependencies and reinstall
#     appropriate versions of modules automatically.
#
#
#   [*mpm*]
#     MPM module to be used by apache. The list of all possible values is
#     +event+, +itk+, +peruser+, +prefork+, +worker+. The list of supported
#     values depends on agent's OS. This parameter is important only, when
#     the selected apache doesn't support loadable MPM modules (in which case
#     we must chose appropriate package with compiled-in MPM module).
#     Apache +2.4+ and later support loadable MPMs.
#
# === Variables
#
# [*::osfamily*]
#   Fact from facter
#
# [*::apachex_installed_version*]
#   Fact added by ptomulik-apachex module
#
# [*::apachex_installed_version*]
#   Fact added by ptomulik-apachex module
#
# [*::apachex_repo_versions*]
#   Fact added by ptomulik-apachex module
#
# === Examples
#
# Use all default parameters
#
#   class { 'apachex::package': }
#
# Stick to '2.2' line of apache. This shall work even with non-versionable
# package providers:
#
#   class { 'apachex::package': ensure => '2.2' }
#
# Require particular version from repository. This works only with versionable
# package providers:
#
#   class { 'apachex::package': ensure => '2.2.13-1' }
#
# === Authors
#
# Pawel Tomulik <ptomulik@meil.pw.edu.pl>
#
# === Copyright
#
# Copyright 2013 Pawel Tomulik, unless otherwise noted.
#
class apachex::package (
  $adminfile = undef,
  $allowcdrom = undef,
  $configfiles = undef,
  $flavor = undef,
  $install_options = undef,
  $package = undef,
  $ensure = undef,
  $provider = undef,
  $responsefile = undef,
  $root = undef,
  $source = undef,
  $uninstall_options = undef,
  $version = undef,
  $mpm = undef,
) {

  Class['apachex'] -> Class['apachex::package']

  if $mpm and !member($apachex::available_mpms, $mpm) {
    fail("Class [apachex::package]: MPM '${mpm}' is not available on this platform")
  }

  if $ensure and $ensure =~ /^2\.[0-9]+$/ {
    $ensure_ver = split($ensure, '.')
    $ensure_minor = $ensure_ver[1]
  }

  if $package {
    $package_name = $package
  } else {
    case $::osfamily {
      'debian' : {
        $package_name = 'apache2'
      }
      'freebsd' : {
        if $ensure_minor {
          if $mpm and $ensure_minor < 4 {
            $package_name = "www/apache2${ensure_minor}-${mpm}-mpm"
          } else {
            $package_name = "www/apache2${ensure_minor}"
          }
        } else {
          $apache_name = 'apache22' # FIXME: it should not be hardcoded as such
          if $mpm {
            $package_name = "www/${apache_name}-${mpm}-mpm"
          } else {
            $package_name = "www/${apache_name}"
          }
        }
      }
      'redhat' : {
        $package_name = 'httpd'
      }
      default : {
        fail("Class [apachex::package]: osfamily '${::osfamily}' is not supported")
      }
    }
  }

  if $ensure_ver {
    if $::apachex_installed_version {
      $installed_name_version = split($::apachex_installed_version, ' ')
      $inst_ver = split($installed_name_version[1], '.')
      if $inst_ver[0] == $ensure_ver[0] and $inst_ver[1] == $ensure_ver[1] {
        # this should keep installed package in current version and it works
        # with all providers
        $package_ensure = present
      }
    }
    if !$package_ensure {
      case $::osfamily {
        'debian' : {
          $package_ensure = apachex_pickup_version($package_name, $ensure, $::apachex_repo_versions)
          if !$package_ensure {
            fail("Class [apachex::package]: ${package_name} ${ensure} not available for installation")
          }
        }
        'freebsd' : {
          # we don't have versionable providers on FreeBSD, sorry;
          # the $package_name shall switch between apache 2.2, 2.4 and so on
          $package_ensure = present
        }
        'redhat' : {
          # TODO: implement
          fail("Class [apachex::package]: not implemented for ${::osfamily}")
        }
        default : {
          fail("Class [apachex::package]: ${::osfamily} is not supported")
        }
      }
    }
  } else {
    # $ensure is not in 2.X form
    $package_ensure = $ensure
  }

  $all_params = {
    adminfile         => $adminfile,
    allowcdrom        => $allowcdrom,
    configfiles       => $configfiles,
    ensure            => $package_ensure,
    flavor            => $flavor,
    install_options   => $install_options,
    name              => $package_name,
    responsefile      => $responsefile,
    root              => $root,
    source            => $source,
    uninstall_options => $uninstall_options,
  }
  $params = apachex_delete_undefs($all_params)
  create_resources('package', { 'apache2' => $params} )
}
