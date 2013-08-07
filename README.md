#apachex

This is very early development. Do not use it in production!

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with [Modulename]](#setup)
    * [What [Modulename] affects](#what-[apachex]-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with [Modulename]](#beginning-with-[Modulename])
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Class: apachex::package](#class-apachexpackage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

A one-maybe-two sentence summary of what the module does/what problem it solves. This is your 30 second elevator pitch for your module. Consider including OS/Puppet version it works with.       

##Module Description

If applicable, this section should have a brief description of the technology the module integrates with and what that integration enables. This section should answer the questions: "What does this module *do*?" and "Why would I use it?"
    
If your module has a range of functionality (installation, configuration, management, etc.) this is the time to mention it.

##Setup

###What [Modulename] affects

* A list of files, packages, services, or operations that the module will alter, impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form. 

###Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled, etc.), mention it here. 
	
###Beginning with [Modulename]	

The very basic steps needed for a user to get the module up and running. 

If your most recent release breaks compatibility or requires particular steps for upgrading, you may wish to include an additional section here: Upgrading (For an example, see http://forge.puppetlabs.com/puppetlabs/firewall).

##Usage

Put the classes, types, and resources for customizing, configuring, and doing the fancy stuff with your module here. 

##Reference

### Class: `apachex::package`

This class represents apache package to install on the target OS.

**Note**: on Debian we assume, that `apt` or `aptitude` provider is used to
manage apache package. Other providers are not well supported. You should
either set the default package provider to be `apt` or `aptitude` or set
`provider` parameter here appropriately. Otherwise your manifests may stop
working (the variables `$apachex::package::actual_name` and
`$apachex::package::actual_version` may have incorrect values).

**Note**: on FreeBSD we assume, that `ports` provider is used to manage apache
package. Other providers are not supported. You should either set the default
package provider to be `ports` or set `provider` parameter here to be `ports`.
Otherwise your manifests may stop working (`$build_options` and `$mpm` will be
ignored in best case, worse things can happen in other cases).

#### Parameters

Most parameters are passed directly to the
[package](http://docs.puppetlabs.com/references/latest/type.html#package)
resource, so they have exactly same meaning and syntax as for the package
resource. Defaults set by `Package { foo => bar }` are fully honored. Here we
mention only the affected package's parameters and new parameters introduced
by `apachex::package`


  - `auto_deinstall`

    Some changes, such as changing MPM on FreeBSD/ports, require to
    de-install currently installed package (e.g. www/apache22) and
    install a new package (e.g. www/apache22-worker-mpm). The
    `auto_deinstall` parameter, if set to `true`, enables automatic
    de-installation of currently installed apache package when necessary.
    By default it is set to `false` for safety, and any de-installation has to
    be done manually by user.

  - `bsd_ports_dir`

    Relevant only on BSD systems. Defines location of the ports tree.
    If `bsd_ports_dir` is not provided (undef), the default locations are
    `/usr/ports` on FreeBSD and OpenBSD and `/usr/pkgsrc` on NetBSD.

  - `bsd_port_dbdir`

    Relevant only on BSD systems. Defines directory where the results of
    configuration OPTIONS are stored. If not provided (undef), the default
    location is `/var/db/ports`.

  - `build_options`

    Options used when the apache package is built (for example in FreeBSD
    ports packages are built on target machine and are customizable via build
    options). The format of this argument depends on the agent's system.

    **FreeBSD (ports)**: `build_options` should be a hash of the form `{ 'OPT1'
    => $val1, ... }`, where `$valX` is either `'on'` or `'off'`, for example:

        class {'apachex::package':
          build_options => {
            'SUEXEC' => on,
            'LDAP' => off,
          }
        }

    **Note**: On FreeBSD/ports `build_options` can be applied fully only if
    the apache package is initially absent (or is going to be reinstalled 
    by puppet due to some other reasons). If apache is already installed
    and only the `build_options` have changed, the new options will be saved to
    options' file (`/var/db/ports/www_apache22/options`, for example), but the
    package will not be reinstalled with new configuration (so, still old
    configuration will be in use). Currently reinstallation is left to user to
    be done "manually". In most cases this may be done by manipulating puppet
    manifests as follows: set `ensure=>absent` for apachex::package, apply your
    manifest, then set new `options` and `ensure` and apply the manifest again.
    Note that `auto_deinstall` doesn't help here.

    We hope, we'll be able to enable some automatization here in future.
    

  - `ensure`

    This has merely same effect as the *ensure* parameter to the `package`
    resource. The difference here is an enhanced versioning. If you pass
    "two-digit" version number (`2.2` for example), it shall still work, even
    if the underlying `package`'s provider is not versionable. Exact version
    numbers (for example `2.4.6-2`) are supported only by versionable
    providers.

    If you pass `2.X` style version number to fully versionable
    `apachex::package`, it will install most recent `2.X` apache package
    available in repositories. In case the apache package is already
    installed, the installation (`$ensure => '2.X'`) is triggered only if the
    installed version does not match the version in `$ensure`. For example,
    if `$ensure == '2.4'` and the installed version is `2.4.6-2`, no upgrade
    will be triggered, even if there is newer version in package repository.
    The upgrade (reinstall) will be triggered, however, if `$ensure == '2.4'`
    and the installed version is, for example, `2.2.22-13`.

    Note, that on some systems, migrations between '2.X' and '2.Y' would
    fail. For example, packages providing apache modules may depend on
    particular (installed) version of apache. Some package managers
    (FreeBSD/ports for example) are not smart enough to handle the changes in
    dependencies and reinstall appropriate versions of modules automatically.


  - `mpm`

    MPM module to be used by apache. Possible values are, for example, `event`,
    `itk`, `peruser`, `prefork`, `worker`. The exact list of supported values
    depends on agent's OS, version of apache package being installed and so on
    (you may define your own list with `mpms_available` parameter). This
    parameter may be important, if the selected apache doesn't support loadable
    MPM modules (in which case we must chose appropriate package with
    compiled-in MPM module). Apache `2.4` and later support loadable MPMs.

    *Example*:

        class {'apachex::package', 
          mpm => 'worker',
        }

    **Note**: on FreeBSD the `mpm` parameter works differently for apache 2.2
    and for apache >= 2.4. In the later case (>=2.4) you may need to uninstall
    apache manually in order to apply changes in `mpm` (the issue is exactly
    same as for `build_options`). If you don't, the new MPM will probably not
    be set (as a default) for apache package and there will be no warning about
    this. Note, that `auto_deinstall` does not help here.

  - `mpm_shared`

    Whether to enable MPM as loadable module (DSO). Defaults to true.
    Relevant only for apache >= 2.4 on systems, where packages are configured
    and built before installation (FreeBSD ports, for example).

    *Example*:

        class {'apachex::package', 
          mpms_shared => true,
        }

  - `mpms_available`

    Normally the `apachex::package` uses pre-determined list of MPMs available
    in package repositories for the target OS. The `$mpm` parameter is
    validated against this list and error is raised if `$mpm` is not on this
    list. If you see, that your value of `$mpm` is not accepted whereas it
    should, you may override this list with your own provided as
    `$mpms_available`.

    *Example*:

        class {'apachex::package', 
          mpm => 'event',
          mpms_available => ['event', 'prefork', 'worker'],
        }

  - `mpms_installed`
    
    Normally the `apachex::package` uses pre-determined list of MPMs installed
    with an apache package being installed. That information is later available
    to manifests as `$apachex::package::actual_mpms` and is used to restrict
    list of mpm modules that can be used at runtime by manifests. If you see
    that the list used by `apachex::package` is wrong/outdated, you may
    override it with your own via `mpms_installed` parameter.

    *Example*:

        class {'apachex::package', 
          mpms_installed => ['event', 'prefork', 'worker'],
        }

  - `package`

    This is the same as `name` parameter to package resource, and will be used
    as package name to be installed as the apache package. Normally
    `apachex::package` tries to determine appropriate name automatically. The
    `package` parameter may be used to set fixed package name.

#### Variables

These variables are required by apachex::package class:

  - `::osfamily`
    fact from facter

  - `::operatingsystem`
    fact from facter

  - `::apachex_installed_version` 
    fact added by ptomulik-apachex module

  - `::apachex_repo_versions`
    fact added by ptomulik-apachex module

These variables are defined by apachex::package and can be used elsewhere:

  - `apachex::package::actual_name`

    Name of the apache package installed by `apachex::package`. This may be,
    for example, `apache2` on Debian, `httpd` on RedHat and `www/apache22` on
    FreeBSD. Once you have included the `apachex::package` class in your
    manifest, you may read from `apachex::package::actual_name` what is actual
    name of the installed package (note, that it depends on several factors
    including agent's OS, MPMs chosen and version of the apache package being
    installed).

  - `apachex::package::actual_version`

    The version of apache package that is installed or is going to be installed
    by the `apachex::package` class.

  - `apachex::package::actual_mpms`

    Regular expression that matches all the names of the installed mpm modules.
    This determines, after all, what MPMs may be enabled at runtime.

#### Examples

Use all default parameters:

    class { 'apachex::package': }

Stick to '2.2' line of apache. This shall work even with non-versionable
package providers:

    class { 'apachex::package': ensure => '2.2' }

Require particular version from repository. This works only with versionable
package providers:

    class { 'apachex::package': ensure => '2.2.13-1' }

Install for use with `worker` MPM

    class { 'apachex::package': mpm => 'worker' } 

Install for use with `event` MPM, automatically reinstall when necessary
(applies to FreeBSD)

    class { 'apachex::package':
      mpm => 'worker',
      auto_deinstall => true,
    } 

Install FreeBSD port of apache with additional options enabled:

    class { 'apachex::package':
      mpm => 'worker',
      build_options => {
        'SUEXEC' => on,
        'PROXY' => on,
        'PROXY_HTTP' => on,
      },
    } 

Install FreeBSD port of apache 2.4, but disable shared MPM modules:

    class { 'apachex::package':
      ensure => '2.4',
      mpm_shared => false,
    } 


##Limitations

This is where you list OS compatibility, version compatibility, etc.

##Development

Since your module is awesome, other users will want to play with it. Let them know what the ground rules for contributing are.

##Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You may also add any additional sections you feel are necessary or important to include here. Please use the `## ` header. 
