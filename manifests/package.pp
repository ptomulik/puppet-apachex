# == Class: apachex::package
#
# This class represents apache package to install on the target OS.
#
# === Parameters
#
# Most parameters are passed directly to the
# package[http://docs.puppetlabs.com/references/latest/type.html#package]
# resource, so they have exactly same meaning as for the package resource.
# Defaults set by +Package { foo => bar }+ are fully honored. Here we mention
# only the affected package's parameters and new parameters introduced
# by +apachex::package+
#
#   [*build_options*]
#     Options used when the apache package is built (for example in FreeBSD
#     ports packages are built on target machine and are customizable via build
#     options). The format of this argument depends on the agent's system.
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
#   [*bsd_ports_dir*]
#     Relevant only on BSD systems. Defines location of the ports three.
#     Defaults to +/usr/ports+ on FreeBSD and OpenBSD and +/usr/pkgsrc+ on
#     NetBSD and to +undef+ on other systems.
#
#   [*bsd_port_dbdir*]
#     Relevant only on BSD systems. Defines directory where the results of
#     configurating OPTIONS are stored. Defaults to +/var/db/ports+.
#
# === Variables
#
# [*::osfamily*]
#   Fact from facter
#
# [*::operatingsystem*]
#   Fact from facter
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
  $build_options = undef,
  $configfiles = undef,
  $flavor = undef,
  $install_options = undef,
  $package = undef,
  $ensure = undef,
  $provider = undef,
  $responsefile = undef,
  $bsd_ports_dir = undef,
  $bsd_port_dbdir = undef,
  $root = undef,
  $source = undef,
  $uninstall_options = undef,
  $mpm = undef,
) {

  Class['apachex'] -> Class['apachex::package']

  if $mpm and !($mpm in $apachex::available_mpms) {
    fail("Class [apachex::package]: MPM '${mpm}' is not available on this platform")
  }

  if $ensure and $ensure =~ /^2\.[0-9]+$/ {
    $ensure_ver = split($ensure, '[.]')
  }

  if $::apachex_installed_version {
    $installed_name_version = split($::apachex_installed_version, ' ')
    $installed_name = $installed_name_version[0]
    $installed_ver = split($installed_name_version[1], '[.]')
  }

  # set $package_name
  if $package {
    $package_name = $package
  } else {
    case $::osfamily {
      'Debian' : {
        $package_name = 'apache2'
      }
      'FreeBSD' : {
        if $ensure_ver {
          if $mpm and $ensure_ver[1] < 4 {
            $package_name = $mpm ? {
              prefork => "www/apache2${ensure_ver[1]}",
              default => "www/apache2${ensure_ver[1]}-${mpm}-mpm"
            }
          } else {
            $package_name = "www/apache2${ensure_ver[1]}"
          }
        } elsif $installed_ver {
          # we can't simply do $package_name = $installed_name
          # because this would ignore changes in $mpm. 
          if $mpm and $installed_ver[1] < 4 {
            $package_name = $mpm ? {
              prefork => "www/apache2${installed_ver[1]}",
              default => "www/apache2${installed_ver[1]}-${mpm}-mpm"
            }
          } else {
            $package_name = "www/apache2${installed_ver[1]}"
            # TODO: select appropriate MPM or dynamic MPM in port options
          }
        } else {
          if $mpm {
            $package_name = $mpm ? {
              prefork => "www/apache22",
              default => "www/apache22-${mpm}-mpm"
            }
          } else {
            $package_name = "www/apache22"
          }
        }
      }
      'RedHat' : {
        $package_name = 'httpd'
      }
      default : {
        fail("Class [apachex::package]: osfamily '${::osfamily}' is not supported")
      }
    }
  }

  # $bsd_port_dbname
  case $::osfamily {
    'FreeBSD', 'OpenBSD', 'NetBSD' : { 
      $bsd_port_dbname = regsubst($package_name,'[^a-zA-Z0-9_]','_')
    }
  }

  # set $package_ensure
  if $ensure_ver {
    if $installed_ver and $installed_ver[0] == $ensure_ver[0] and $installed_ver[1] == $ensure_ver[1] {
      # keep installed package in current version, as it generally matches
      # $ensure (2.X form); 
      $package_ensure = present
    } else {
      case $::osfamily {
        'Debian', 'RedHat' : {
          $package_ensure = apachex_pickup_version($package_name, $ensure, $::apachex_repo_versions)
          if !$package_ensure {
            fail("Class [apachex::package]: ${package_name} ${ensure} not available for installation")
          }
        }
        'FreeBSD' : {
          # we don't have versionable providers on FreeBSD, sorry;
          # the $package_name shall switch between apache 2.2, 2.4, etc.
          $package_ensure = present
          # FIXME: it would be good to check if there is $package_name in repo,
          #        and eventually fail here (before we uninstall current
          #        package)
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

  # handle $bsd_ports_dir
  if $bsd_ports_dir {
    $package_bsd_ports_dir = $bsd_ports_dir
  } else {
    $package_bsd_ports_dir = $::operatingsystem ? {
      'FreeBSD' => "/usr/ports",
      'OpenBSD' => "/usr/ports",
      'NetBSD'  => "/usr/pkgsrc",
      default   => undef
    }
  }

  # handle $bsd_port_dbdir
  if $bsd_port_dbdir {
    $package_bsd_port_dbdir = $bsd_port_dbdir
  } else {
    $package_bsd_port_dbdir = '/var/db/ports'
  }

  # handle $build_options
  if $build_options {
    case $::osfamily {
      'FreeBSD' : {
        fail('build options not implemented yet')
        # TODO: implement this path
#        validate_hash($build_options)
#
#        $make_mpm_options = ""
#        $make_user_options = join_keys_to_values($build_options, '=')
#        $make_options = "${make_user_options}${make_mpm_options}"
#        # FIXME: get rid of exec(s), develop resource for ports configuration
#        # FIXME: config should be ran only if $ensure is not 'absent'/'purge'?
#        # FIXME: config should be ran only if:
#        #        1. apache is not installed
#        #        2. $make_options differ from thes options for currently
#        #           installed apache
#        exec { "apachex::package apply build_options":
#          # FIXME: path shouldn't be hardcoded
#          path        => [ '/sbin', '/bin', '/usr/sbin', '/usr/bin',
#                           '/usr/local/sbin', '/usr/local/bin' ],
#          command     => "make config-default ${make_options}",
#          cwd         => "${package_bsd_ports_dir}/${package_name}",
#          environment => ['BATCH=y'],
#          before      => Package['apache2'],
#          refresh     => Package['apache2'],
#          creates     => "${package_bsd_port_dbdir}/${bsd_port_dbname}/options",
#        }
      }
      default : {
        fail("Class [apachex::package]: build_options not supported on ${::osfamily} osfamily")
      }
    }
  }


  # additioal OS-dependent tricks
  case $::osfamily {
    'FreeBSD': {
      if $installed_name and $installed_name != $package_name {
        # remove unwanted package 
        ensure_resource('package', $installed_name_version[0], {
          ensure  => absent,
          before  => Package['apache2'],
          require => File_line['APACHE_PORT in /etc/make.conf'],
        })
      }
      # Configure ports to have apache module packages dependent on correct
      # version of apache package (apache22, apache22-worker-mpm, ...)
      file_line { 'APACHE_PORT in /etc/make.conf':
        ensure => $package_ensure ? {
          'absent' => 'absent',
          'purged' => 'absent',
          default  => 'present'
        },
        path   => '/etc/make.conf',
        line   => "APACHE_PORT=${package_name}",
        match  => "^\\s*#?\\s*APACHE_PORT\\s*=\\s*",
        before => Package['apache2'],
      }
    }
  }

  $all_params = {
    adminfile         => $adminfile,
    allowcdrom        => $allowcdrom,
    configfiles       => $configfiles,
    ensure            => $package_ensure,
    flavor            => $flavor,
    install_options   => $install_options,
    name              => $package_name,
    provider          => $provider,
    responsefile      => $responsefile,
    root              => $root,
    source            => $source,
    uninstall_options => $uninstall_options,
  }
  $params = apachex_delete_undefs($all_params)
  create_resources('package', {'apache2' => $params})
}
