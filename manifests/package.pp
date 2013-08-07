# == Class: apachex::package
#
# This class represents apache package to install on the target OS.
#
# === Parameters
#
# TODO: write documentation for apachex::package parameters
#
# === Variables
#
# TODO: write documentation for apachex::package variables
#
# === Examples
#
# TODO: write examples for apachex::package
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
      $installable_mpms = ['event', 'itk', 'prefork', 'worker']
    }
    'FreeBSD' : {
      if ($ensure_ver and $ensure_ver[1]>=4) or ($installed_ver and $installed_ver[1]>=4) {
        $installable_mpms = ['event', 'prefork', 'worker']
      } else {
        $installable_mpms = ['event', 'itk', 'peruser', 'prefork', 'worker']
      }
    }
    'RedHat' : {
      $installable_mpms = ['event', 'prefork', 'worker']
    }
    default  : {
      # these two are supported on most systems ...
      $installable_mpms = ['prefork', 'worker']
    }
  }

  if $mpm and !($mpm in $installable_mpms) {
    fail("Class [apachex::package]: ${mpm} MPM is not available.")
  }


  #
  # set $actual_name
  #
  if $package {
    $actual_name = $package
  } else {
    case $::osfamily {
      'Debian' : {
        if $mpm {
          # NOTE: for apache>=2.4 the apache2-mpm-xxx packages are just
          # transitional packages and we could better install just apache2.
          # However, we don't know in advance which version is going to be
          # installed, so we choose the apache2-mpm-xxx just for case.
          $actual_name = "apache2-mpm-${mpm}"
        } else {
          $actual_name = 'apache2'
        }
      }
      'FreeBSD' : {
        if $ensure_ver {
          if $mpm and $ensure_ver[1] < 4 {
            $actual_name = $mpm ? {
              prefork => "www/apache2${ensure_ver[1]}",
              default => "www/apache2${ensure_ver[1]}-${mpm}-mpm"
            }
          } else {
            $actual_name = "www/apache2${ensure_ver[1]}"
          }
        } elsif $installed_ver {
          # we can't simply do $actual_name = $installed_name
          # because this would ignore changes in $mpm.
          if $mpm and $installed_ver[1] < 4 {
            $actual_name = $mpm ? {
              prefork => "www/apache2${installed_ver[1]}",
              default => "www/apache2${installed_ver[1]}-${mpm}-mpm"
            }
          } else {
            $actual_name = "www/apache2${installed_ver[1]}"
          }
        } else {
          if $mpm {
            $actual_name = $mpm ? {
              prefork => 'www/apache22',
              default => "www/apache22-${mpm}-mpm"
            }
          } else {
            $actual_name = 'www/apache22'
          }
        }
      }
      'RedHat' : {
        $actual_name = 'httpd'
      }
      default : {
        fail("Class [apachex::package]: osfamily '${::osfamily}' is not supported")
      }
    }
  }

  #
  # set $actual_version and $actual_ensure
  #
  if $ensure_ver {
    if $installed_ver and $installed_ver[0] == $ensure_ver[0] and $installed_ver[1] == $ensure_ver[1] {
      # keep installed package in current version, as it generally matches
      # the provided $ensure in 2.X form;
      $actual_version = join($installed_ver, '.')
      $actual_ensure = present
    } else {
      case $::osfamily {
        'Debian', 'RedHat' : {
          $actual_version = apachex_pickup_version($actual_name, $ensure, $::apachex_repo_versions)
          if !$actual_version {
            fail("Class [apachex::package]: ${actual_name} ${ensure} not available for installation")
          }
          $actual_ensure = $actual_version
        }
        'FreeBSD' : {
          # we don't have versionable providers on FreeBSD, sorry; the
          # $actual_name shall switch between www/apache22, www/apache24, etc.
          $actual_version = apachex_pickup_version($actual_name, $ensure, $::apachex_repo_versions)
          if ! $actual_version {
            # raise error before we go to uninstall current package
            fail("Class [apachex::package]: ${actual_name} ${ensure} not available for installation")
          }
          $actual_ensure = present
        }
        default : {
          fail("Class [apachex::package]: ${::osfamily} is not supported")
        }
      }
    }
  } else {
    # $ensure is not in 2.X form
    if $installed_ver and $ensure != 'latest' {
      $actual_version = join($installed_ver, '.')
    } else {
      $actual_version = apachex_pickup_version($actual_name, '2', $::apachex_repo_versions)
    }
    $actual_ensure = $ensure
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
            $err_mpm1 = "${mpm} is not an MPM supported by ${actual_name}"
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
        create_resources('bsdportconfig', { "${actual_name}" => $port_params })

        # NOTE: changes in options are ignored once the apache package is
        #       installed (and is not going to be reinstalled here). We have no
        #       possibility to reinstall packages (damn you FreeBSD and your
        #       ports!). We may try to remove the package, set new port
        #       configuration and then install it again but it won't work in
        #       most cases. Once you have installed apache and other ports
        #       (external apache modules for example) which depend on it, ports
        #       will refuse to uninstall apache because this would broke
        #       dependencies. We also have no option to ignore dependencies.
        #       Uninstalling all the dependent ports is much too dangerous.
        Bsdportconfig[$actual_name] -> Package['apache2']
      }
      default : {
        fail("Class [apachex::package]: build_options not supported on ${::osfamily} osfamily")
      }
    }
  }

  # Additional OS-dependent hacks
  case $::osfamily {
    'FreeBSD': {
      if $installed_name and $installed_name != $actual_name {
        # FreeBSD/ports can't automatically resolve conflicts, we must
        # first uninstall colliding package manually.
        if $auto_deinstall {
          ensure_resource('package', $installed_name_version[0], {
            ensure  => absent,
            before  => Package['apache2'],
            require => File_line['APACHE_PORT in /etc/make.conf'],
          })
        } else {
          $err_deinst1 ="Can't install ${actual_name} because ${installed_name} is already installed"
          $err_deinst2 ="Either uninstall ${installed_name} manually or set auto_deinstall=>true"
          fail("Class [apachex::package]: ${err_deinst1}. ${err_deinst2}.")
        }
      }
      # Configure ports to have apache module packages dependent on correct
      # version of apache package (apache22, apache22-worker-mpm, ...)
      $apache_port_line_ensure = $actual_ensure ? {
        'absent' => 'absent',
        'purged' => 'absent',
        default  => 'present'
      }
      file_line { 'APACHE_PORT in /etc/make.conf':
        ensure => $apache_port_line_ensure,
        path   => '/etc/make.conf',
        line   => "APACHE_PORT=${actual_name}",
        match  => '^\s*#?\s*APACHE_PORT\s*=\s*',
        before => Package['apache2'],
      }
    }
  }

  $all_params = {
    adminfile         => $adminfile,
    allowcdrom        => $allowcdrom,
    configfiles       => $configfiles,
    ensure            => $actual_ensure,
    flavor            => $flavor,
    install_options   => $install_options,
    name              => $actual_name,
    provider          => $provider,
    responsefile      => $responsefile,
    root              => $root,
    source            => $source,
    uninstall_options => $uninstall_options,
  }
  $params = apachex_delete_undefs($all_params)
  create_resources('package', {'apache2' => $params})
}
