# == Class: apachex::package
#
# This class represents apache package to install on the target OS.
#
# **Note**: on FreeBSD we assume, that ports are used to manage apache package.
# Other providers are not supported. You should either set the default package
# provider to be +ports+ or set +provider+ parameter here to be +'ports'+.
# Otherwise your manifests may stop working ($build_options and $mpm will
# be ignored in best case, worse things can happen in other cases).
#
# === Parameters
#
# Most parameters are passed directly to the
# package[http://docs.puppetlabs.com/references/latest/type.html#package]
# resource, so they have exactly same meaning and syntax as for the package
# resource. Defaults set by +Package { foo => bar }+ are fully honored. Here we
# mention only the affected package's parameters and new parameters introduced
# by +apachex::package+
#
#
#   [*auto_deinstall*]
#     Some changes, such as changing MPM on FreeBSD/ports, require to
#     de-install currently installed package (e.g. www/apache22) and
#     install a new package (e.g. www/apache22-worker-mpm). The
#     +auto_deinstall+ parameter, if set to true, allows for automatic
#     de-installation of currently installed apache package when necessary.
#     By default it is set to +false+, and any de-installation is forced to
#     be done manually by user.
#
#   [*bsd_ports_dir*]
#     Relevant only on BSD systems. Defines location of the ports tree.
#     Defaults to +/usr/ports+ on FreeBSD and OpenBSD and +/usr/pkgsrc+ on
#     NetBSD and to +undef+ on other systems.
#
#   [*bsd_port_dbdir*]
#     Relevant only on BSD systems. Defines directory where the results of
#     configuration OPTIONS are stored. Defaults to +/var/db/ports+.
#
#   [*build_options*]
#     Options used when the apache package is built (for example in FreeBSD
#     ports packages are built on target machine and are customizable via build
#     options). The format of this argument depends on the agent's system.
#
#     **Note**: On FreeBSD/ports +build_options+ can be applied fully only if
#     the apache package is initially absent (or is going to be reinstalled
#     by puppet due to some other reasons). If apache is already installed
#     and only the build_options have changed in your manifest, the new options
#     will be saved to options' file (/var/db/ports/xxx/options), but the
#     package will not be reinstalled with new configuration (so, still old
#     configuration will be in use). This behavior may be changed in future.
#     Currently reinstallation is left to user to be done "manually". In
#     simplest case it may be done manually by manipulating puppet manifests
#     as follows: set +ensure=>absent+ for apachex::package, apply your
#     manifest, then set new +options+ and +ensure+ and apply the manifest
#     again.
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
#   [*mpm_shared*]
#     Whether to enable MPM as loadable module (DSO). Defaults to true.
#     Relevant only for apache >= 2.4 on systems, where pre-compiled
#     packages are not used (FreeBSD ports, for example).
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
# Copyright 2013 Pawel Tomulik.
#
class apachex::package (
  $adminfile = undef,
  $allowcdrom = undef,
  $auto_deinstall = false,
  $bsd_port_dbdir = undef,
  $bsd_ports_dir = undef,
  $build_options = undef,
  $configfiles = undef,
  $ensure = undef,
  $flavor = undef,
  $install_options = undef,
  $mpm = undef,
  $mpm_shared = true,
  $package = undef,
  $provider = undef,
  $responsefile = undef,
  $root = undef,
  $source = undef,
  $uninstall_options = undef,
) {

  if $ensure and $ensure =~ /^2\.[0-9]+$/ {
    $ensure_ver = split($ensure, '[.]')
  }

  if $::apachex_installed_version {
    $installed_name_version = split($::apachex_installed_version, ' ')
    $installed_name = $installed_name_version[0]
    $installed_ver = split($installed_name_version[1], '[.]')
  }

  #
  # Define available MPMs
  #
  case $::osfamily {
    'Debian' : {
      $available_mpms = ['event', 'itk', 'prefork', 'worker']
    }
    'FreeBSD' : {
      if ($ensure_ver and $ensure_ver[1]>=4) or ($installed_ver and $installed_ver[1]>=4) {
        $available_mpms = ['event', 'prefork', 'worker']
      } else {
        $available_mpms = ['event', 'itk', 'peruser', 'prefork', 'worker']
      }
    }
    'RedHat' : {
      $available_mpms = ['event', 'prefork', 'worker']
    }
    default  : {
      # these two are supported on most systems ...
      $available_mpms = ['prefork', 'worker']
    }
  }

  if $mpm and !($mpm in $available_mpms) {
    fail("Class [apachex::package]: ${mpm} MPM is not available.")
  }


  #
  # set $package_name
  #
  if $package {
    $package_name = $package
  } else {
    case $::osfamily {
      'Debian' : {
        if $mpm {
          # NOTE: for apache>=2.4 the apache2-mpm-xxx packages are just
          # transitional packages and we could better install just apache2.
          # However, we don't know in advance which version is going to be
          # installed, so we choose the apache2-mpm-xxx just for case.
          $package_name = "apache2-mpm-${mpm}"
        } else {
          $package_name = 'apache2'
        }
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
          }
        } else {
          if $mpm {
            $package_name = $mpm ? {
              prefork => 'www/apache22',
              default => "www/apache22-${mpm}-mpm"
            }
          } else {
            $package_name = 'www/apache22'
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

  #
  # set $package_ensure
  #
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
          # we don't have versionable providers on FreeBSD, sorry; the
          # $package_name shall switch between www/apache22, www/apache24, etc.
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

  #
  # handle $build_options
  #
  if $build_options {
    case $::osfamily {
      'FreeBSD' : {
        validate_hash($build_options)

        if $ensure_ver and $ensure_ver[1] >= 4 {
          if $mpm_shared {
            $mpm_shared_optval = 'on'
          } else {
            $mpm_shared_optval = 'off'
          }
          if $mpm {
            # NOTE: at the time of this writing (aug 06, 2013) www/apache24
            # offers only three MPMs: event, prefork and worker
            $err_mpm1 = "${mpm} is not an MPM supported by ${package_name}"
            validate_re($mpm, '^(event|prefork|worker)$', $err_mpm1)
            $mpm_options = {
              'MPM_EVENT'   => $mpm ? { 'event' =>'on', default => 'off' },
              'MPM_PREFORK' => $mpm ? { 'prefork' =>'on', default => 'off' },
              'MPM_WORKER'  => $mpm ? { 'worker' =>'on', default => 'off' },
              'MPM_SHARED'  => $mpm_shared_optval,
            }
          } else {
            $mpm_options = {
              'MPM_EVENT'   => 'off',
              'MPM_PREFORK' => 'on',
              'MPM_WORKER'  => 'off',
              'MPM_SHARED'  => $mpm_shared_optval,
            }
          }
        } else {
          $mpm_options = {}
        }

        $port_options = merge($mpm_options, $build_options)
        $port_params = apachex_delete_undefs({
          portsdir   => $bsd_ports_dir,
          port_dbdir => $bsd_port_dbdir,
          options    => $port_options,
        })
        create_resources('bsdportconfig', { "${package_name}" => $port_params })

        # NOTE: changes in options are ignored once the apache package is
        #       installed (and is not going to be uninstalled). We have no
        #       possibility to reinstall packages (damn you FreeBSD and your
        #       ports!). We may try to remove the package, set new port
        #       configuration and then install it again but it won't work in
        #       most cases. Once you have installed apache and other ports
        #       (external apache modules for example) which depend on it, ports
        #       will refuse to uninstall apache because this would broke
        #       dependencies. We also have no option to ignore dependencies.
        #       Uninstalling all the dependent ports is much too dangerous.
        Bsdportconfig[$package_name] -> Package['apache2']
      }
      default : {
        fail("Class [apachex::package]: build_options not supported on ${::osfamily} osfamily")
      }
    }
  }

  # Additional OS-dependent hacks
  case $::osfamily {
    'FreeBSD': {
      if $installed_name and $installed_name != $package_name {
        # FreeBSD/ports can't automatically resolve conflicts, we must
        # first uninstall colliding package manually.
        if $auto_deinstall {
          ensure_resource('package', $installed_name_version[0], {
            ensure  => absent,
            before  => Package['apache2'],
            require => File_line['APACHE_PORT in /etc/make.conf'],
          })
        } else {
          $err_deinst1 ="Can't install ${package_name} because ${installed_name} is already installed"
          $err_deinst2 ="Either uninstall ${installed_name} manually or set auto_deinstall=>true"
          fail("Class [apachex::package]: ${err_deinst1}. ${err_deinst2}.")
        }
      }
      # Configure ports to have apache module packages dependent on correct
      # version of apache package (apache22, apache22-worker-mpm, ...)
      $apache_port_line_ensure = $package_ensure ? {
        'absent' => 'absent',
        'purged' => 'absent',
        default  => 'present'
      }
      file_line { 'APACHE_PORT in /etc/make.conf':
        ensure => $apache_port_line_ensure,
        path   => '/etc/make.conf',
        line   => "APACHE_PORT=${package_name}",
        match  => '^\s*#?\s*APACHE_PORT\s*=\s*',
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
