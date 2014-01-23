#apachex

This is very early development. Do not use it in production!

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does](#module-description)
3. [Setup - The basics of getting started with Apachex](#setup)
    * [What Apachex affects](#what-apachex-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with Apachex](#beginning-with-apachex)
4. [Usage - The classes, defined types, facts and resources](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes and Defined Types](#classes-and-defined-types)
    * [Resource Types and Providers](#resource-types-and-providers)
    * [Facts](#facts)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##<a id="overview"></a>Overview

The Apachex module allows you to set up and configure apache server, define
virtual hosts and manage web services with minimal effort.

##<a id="module-description"></a>Module Description


##<a id="setup"></a>Setup

###<a id="what-apachex-affects"></a>What Apachex affects

* A list of files, packages, services, or operations that the module will alter, impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form.

###<a id="setup-requirements"></a>Setup Requirements

If your module requires anything extra before setting up (pluginsync enabled, etc.), mention it here.

###<a id="beginning-with-apachex"></a>Beginning with Apachex

The very basic steps needed for a user to get the module up and running.

If your most recent release breaks compatibility or requires particular steps for upgrading, you may wish to include an additional section here: Upgrading (For an example, see http://forge.puppetlabs.com/puppetlabs/firewall).

##<a id="usage"></a>Usage

Put the classes, types, and resources for customizing, configuring, and doing the fancy stuff with your module here.

###<a id="facts"></a>Facts

##<a id="reference"></a>Reference

###<a id="classes-and-defined-types"></a>Classes and Defined Types

- [apachex::package class](#apachexpackage-class)
  - [apachex::pacakge class parameters](#apachexpackage-class-parameters)

####<a id="apachexpackage-class"></a>apachex::package class

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
Otherwise your manifests may stop working (`$package_settings` and `$mpm` will be
ignored in best case, worse things can happen in other cases).

[Back to index](#classes-and-defined-types)

#####<a id="apachexpackage-class-parameters"></a>apachex::package class parameters

Most parameters are passed directly to the
[package](http://docs.puppetlabs.com/references/latest/type.html#package)
resource, so they have exactly same meaning and syntax as for the package
resource. Defaults set by `Package { foo => bar }` are fully honored. Here we
mention only the affected package's parameters and new parameters introduced
by `apachex::package`


  - **auto_deinstall**

    Some changes, such as changing MPM on FreeBSD/ports, require to
    de-install currently installed package (e.g. www/apache22) and
    install a new package (e.g. www/apache22-worker-mpm). The
    **auto_deinstall** parameter, if set to `true`, enables automatic
    de-installation of currently installed apache package when necessary.
    By default it is set to `false` for safety, and any de-installation has to
    be done manually by user.

  - **bsd_ports_dir**

    Relevant only on BSD systems. Defines location of the ports tree.
    If **bsd_ports_dir** is not provided (undef), the default locations are
    `/usr/ports` on FreeBSD and OpenBSD and `/usr/pkgsrc` on NetBSD.

  - **bsd_port_dbdir**

    Relevant only on BSD systems. Defines directory where the results of
    configuration OPTIONS are stored. If not provided (undef), the default
    location is `/var/db/ports`.

  - **package_settings**

    Options used when the apache package is built (for example in FreeBSD
    ports packages are built on target machine and are customizable via build
    options). The format of this argument depends on the agent's system.

    **FreeBSD (ports)**: **package_settings** should be a hash of the form `{
    'OPT1' => $val1, ... }`, where `$valX` is either `'on'` or `'off'`, for
    example:

    ```puppet
    class {'apachex::package':
      package_settings => {
        'SUEXEC' => on,
        'LDAP' => off,
        }
    }
    ```

    **Note**: On FreeBSD/ports **package_settings** can be applied fully only
    if the apache package is initially absent (or is going to be reinstalled
    by puppet due to some other reasons). If apache is already installed
    and only the **package_settings** have changed, the new options will be
    saved to options' file (`/var/db/ports/www_apache22/options`, for example),
    but the package will not be reinstalled with new configuration (so, still
    old configuration will be in use). Currently reinstallation is left to user
    to be done "manually". In most cases this may be done by manipulating
    puppet manifests as follows: set `ensure=>absent` for apachex::package,
    apply your manifest, then set new `options` and `ensure` and apply the
    manifest again. Note that **auto_deinstall** doesn't help here.

    We hope, we'll be able to enable some automatization here in future.

  - **ensure**

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


  - **mpm**

    MPM module to be used by apache. Possible values are, for example, `event`,
    `itk`, `peruser`, `prefork`, `worker`. The exact list of supported values
    depends on agent's OS, version of apache package being installed and so on
    (you may define your own list with `mpms_available` parameter). This
    parameter may be important, if the selected apache doesn't support loadable
    MPM modules (in which case we must chose appropriate package with
    compiled-in MPM module). Apache `2.4` and later support loadable MPMs.

    *Example*:

    ```puppet
    class {'apachex::package',
      mpm => 'worker',
    }
    ```

    **Note**: on FreeBSD the **mpm** parameter works differently for apache 2.2
    and for apache >= 2.4. In the later case (>=2.4) you may need to uninstall
    apache manually in order to apply changes in **mpm** (the issue is exactly
    same as for **package_settings**). If you don't, the new MPM will probably
    not be set (as a default) for apache package and there will be no warning
    about this. Note, that **auto_deinstall** does not help here.

  - **mpm_shared**

    Whether to enable MPM as loadable module (DSO). Defaults to true.
    Relevant only for apache >= 2.4 on systems, where packages are configured
    and built before installation (FreeBSD ports, for example).

    *Example*:

    ```puppet
    class {'apachex::package',
      mpms_shared => true,
    }
    ```

  - **mpms_available**

    Normally the `apachex::package` uses pre-determined list of MPMs available
    in package repositories for the target OS. The `$mpm` parameter is
    validated against this list and error is raised if `$mpm` is not on this
    list. If you see, that your value of `$mpm` is not accepted whereas it
    should, you may override this list with your own provided as
    `$mpms_available`.

    *Example*:

    ```puppet
    class {'apachex::package',
      mpm => 'event',
      mpms_available => ['event', 'prefork', 'worker'],
    }
    ```

  - **mpms_installed**

    Normally the `apachex::package` uses pre-determined list of MPMs installed
    with an apache package being installed. That information is later available
    to manifests as `$apachex::package::actual_mpms` and is used to restrict
    list of mpm modules that can be used at runtime by manifests. If you see
    that the list used by `apachex::package` is wrong/outdated, you may
    override it with your own via **mpms_installed** parameter.

    *Example*:

    ```puppet
    class {'apachex::package',
      mpms_installed => ['event', 'prefork', 'worker'],
    }
    ```

  - **package**

    This is the same as `name` parameter to package resource, and will be used
    as package name to be installed as the apache package. Normally
    `apachex::package` tries to determine appropriate name automatically. The
    **package** parameter may be used to set fixed package name.

    [Back to index](#classes-and-defined-types)

[Back to index](#classes-and-defined-types)

###<a id="resource-types-and-providers"></a>Resource Types and Providers

- [apachex_instance](#apachex_instance)
  - [apachex_instance parameters](#apachex_instance-parameters)
- [apachex_modules](#apachex_modules)
  - [apachex_modules parameters](#apachex_modules-parameters)

####<a id="apachex_instance"></a>apachex\_instance

Instance of apache server, supports running multiple instances of apache.

Some platforms allow running multiple instances of apache server with
different configurations and as different users. This pattern is used by
to setup hosting environments with decent privilege separation
(for example, multiple instances of http server behind a reverse proxy).

The **apachex_instance** resource represents single instance of a running
apache server in puppet manifest. It's main puprose is to autorequire other
"per instance" resources that are necessary to setup the instance properly. It
also maintains resources that can't be handled by other resource types.

As an example of system resources maintained by **apachex_instance** one can
take the `freebsd` provider which maintains a configuration file named
`/etc/rc.conf.d/${apache_name}_instances.conf`. The file defines a list of
apache instances that should be started at boot time. See
[wiki article](http://wiki.apache.org/httpd/RunningMultipleApacheInstances)
for more details.

Note that **apachex_instance** does not start any instances by it's own and
doesn't create any additional resources. It just sets soft dependence to
other resources, which should be defined in manifest file for each
apache instance.

[Back to index](#resource-types-and-providers)

#####<a id="apachex_instance-parameters"></a>apachex\_instance parameters

- **name** - identifies instances of the **apachex_instance** resource. The
  **name** must be a string matching `/^[a-zA-Z_]\w*$/` regular expression,
  that is it must be a valid identifier such as `foo_bar24`.
- **modules** - (default: =**name**) name of [apachex_modules](#apachex_modules)
  for this apache instance. It defines the module list to be loaded at startup
  by this apache instance. The **modules** must be a string.
- **instance_options** - (default: `{}`) additional (provider-specific) options. The
  **instance_options** must be a Hash.

[Back to index](#resource-types-and-providers)

####<a id="apachex_modules"></a>apachex\_modules

Apache modules for an apache instance.

This resource maintains list of modules that shall be loaded at startup by an
apache instance. This list shall not include MPM modules.

**Example**:

```puppet
apachex_modules { foo:
  modules => {
    access_compat => 'mod_access_compat.so'
    authn_file => '/usr/lib/apache2/modules/mod_authn_file.so',
  }
}
```

[Back to index](#resource-types-and-providers)

#####<a id="apachex_modules-parameters"></a>apachex\_modules parameters

- **name** - identifies instances of the **apachex_modules** resource.
- **modules** - modules gathered by this resource. This is a hash in form

  ```puppet
  $modules = { xxx => '/path/to/mox_xxx.so', ...  }
  ```

  The keys and values in the hash correspond to *module* and *filename*
  parameter of the
  [LoadModule](http://httpd.apache.org/docs/current/mod/mod_so.html#loadmodule)
  directive respectively. Filenames may be given as either absolute paths or
  paths relative to `ServerRoot`. The above `key => value` pair shall generate
  the following **LoadModule** directive:

  ```apache
  LoadModule xxx_module /path/to/mod_xxx.so
  ```

  assuming that **id_suffix** is set to `_module` (which is the
  default).

  Keys must match `/^[a-zA-Z_]\w*$/` expression, that is they must be
  valid identifiers. Values must be Strings or Symbols.
- **id_suffix** - (default: `'_module'`) sets the suffix used for *module*
  parameter to the
  [LoadModule](http://httpd.apache.org/docs/current/mod/mod_so.html#loadmodule)
  directive. The following code:

  ```puppet
  apachex_modules{xxx:
    modules => { 
      foo => '/path/to/mod_foo.so',
      bar => '/path/to/mod_bar.so' 
    },
    id_suffix => '_sfx',
  }
  ```

  shall generate:


  ```apache
  LoadModule foo_sfx /path/to/mod_foo.so
  LoadModule bar_sfx /path/to/mod_bar.so
  ```

  The **id_suffix** parameter must be a String.

- **id_map** - (default: `{}`) maps **modules** to *module ids* (used by
  [LoadModule](http://httpd.apache.org/docs/current/mod/mod_so.html#loadmodule)).
  This provides a way to define custom *module ids* for modules, which for some
  reason can not use default *module ids* created by concatenating module name
  with **id_suffix**.

  This is a hash in form:

  ```puppet
  $id_map = { 'xxx' => 'xxx_module', ... }
  ```

  which maps module names given as keys in **modules** to *module ids*
  used by **LoadModule** directives. For example, the following manifest


  ```puppet
  apachex_modules{xxx:
    modules => {
      foo => '/path/to/mod_foo.so',
      bar => '/path/to/mod_bar.so'
    }
    id_map => {
      foo => custom_foo_id
    }
  }
  ```

  shall generate:

  ```apache
      LoadModule custom_foo_id /path/to/mod_foo.so
      LoadModule bar_module /path/to/mod_bar.so
  ```

  The **id_map** must be a Hash. Keys and values in **id_map** must match
  `/^[a-zA-Z_]\w*$/` regular expression, that is they must form valid
  identifiers.

[Back to index](#resource-types-and-providers)

####<a id="variables"></a>Variables

These variables are required by apachex::package class:

  - `::osfamily`
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

####<a id="examples"></a>Examples

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
      package_settings => {
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


##<a id="limitations"></a>Limitations

This is where you list OS compatibility, version compatibility, etc.

##<a id="development"></a>Development

Since your module is awesome, other users will want to play with it. Let them know what the ground rules for contributing are.
