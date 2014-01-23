# == Define: apachex::conf
#
# Single configuration file. Note that it has a lot of parameters. Instead of
# using this type directly, you may use the apachex::conf_wrapper.
#
# === Parameters
#
# [*path*]
#   The path to the configuration file to manage. Defaults to $title.
#   For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-path.
#
# [*ensure*]
#   Whether the file should exist, and if so what kind of file it
#   should be. Possible values are present, absent, file, and link.
#   For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-ensure.
#   
# [*backup*]
#   Whether (and how) file content should be backed up before being replaced.
#   For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-backup.
#
# [*checksum*]
#   The checksum type to use when determining whether to replace a file's
#   contents. For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-checksum.
#
# [*content*]
#   The desired contents of a file, as a string. This attribute is mutually
#   exclusive with source and target.
#   For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-content.
#
# [*force*]
#   Perform the file operation even if it will destroy one or more directories.
#   For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-force.
#
# [*group*]
#   Which group should own the file. Argument can be either a group name or a
#   group ID. For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-group.
#
# [*ignore*]
#   A parameter which omits action on files matching specified patterns during
#   recursion. For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-ignore.
#
# [*links*]
#   How to handle links during file actions. For details see documentation of
#   the file resource at 
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-links.
#
# [*mode*]
#   The desired permissions mode for the file, in symbolic or numeric notation.
#   For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-mode.
#
# [*owner*]
#   The user to whom the file should belong. Argument can be a user name or a
#   user ID. For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-owner.
#
# [*provider*]
#   The specific backend to use for the file resource. For details see
#   documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-provider.
#
# [*purge*]
#   Whether unmanaged files should be purged. This option only makes sense when
#   managing directories with recurse => true. For details see documentation of
#   the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-purge.
#
# [*recurse*]
#   Whether and how to do recursive file management. For details see
#   documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-recurse.
#
# [*recurselimit*]
#   How deeply to do recursive management. For details see documentation of the
#   file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-recurselimit.
#
# [*replace*]
#   Whether to replace a file or symlink that already exists on the local system
#   but whose content doesn’t match what the source or content attribute
#   specifies. For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-replace.
#
# [*selinux_ignore_defaults*]
#   If this is set then Puppet will not ask SELinux (via matchpathcon) to supply
#   defaults for the SELinux attributes (seluser, selrole, seltype, and
#   selrange). For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-selinux_ignore_defaults.
#
# [*selrange*]
#   What the SELinux range component of the context of the file should be. For
#   details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-selrange.
#
# [*selrole*]
#   What the SELinux role component of the context of the file should be. For
#   details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-selrole.
#
# [*seltype*]
#   What the SELinux type component of the context of the file should be.
#   For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-seltype.
#
# [*seluser*]
#   What the SELinux user component of the context of the file should be.
#   For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-seluser.
#
# [*show_diff*]
#   Whether to display differences when the file changes, defaulting to true.
#   For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-show_diff.
#
# [*source*]
#   A source file, which will be copied into place on the local system.
#   For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-source.
#
# [*source_permissions*]
#   Whether (and how) Puppet should copy owner, group, and mode permissions from
#   the source to file resources when the permissions are not explicitly
#   specified. For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-permissions.
#
# [*sourceselect*]
#   Whether to copy all valid sources, or just the first one. For details see
#   documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-sourceselect.
#
# [*target*]
#   The target for creating a link. For details see documentation of the file
#   resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-target.
#
# [*template*]
#   A template file used to generate this config's contents.
#
# [*subst*]
#   A hash defining parameters to be substituted in the configuration file:
#
#   The $subst hash must define all the variables used by the $template.
#
# === Variables
#
# The apachex::conf defines following defaults:
#
# TODO:
#
# The apachex::conf requires following variables:
#
# TODO:
#
# === Examples
#
#       apachex::conf {'/etc/apache2/mods-available/authz_core.load':
#           subst          =>  { 
#               'mod_id'   => 'authz_core_module',
#               'mod_path' => '/usr/lib/apache2/modules/mod_authz_core.so'
#           }
#           template       => 'debian/mods-available/module.load.erb'
#       }
#
# === Authors
#
# Pawel Tomulik <ptomulik@meil.pw.edu.pl>
#
# === Copyright
#
# Copyright 2014 Pawel Tomulik.
#
define apachex::conf(
    $path                       = undef,
    $ensure                     = undef,
    $backup                     = undef,
    $checksum                   = undef,
    $content                    = undef,
    $force                      = undef,
    $group                      = undef,
    $ignore                     = undef,
    $links                      = undef,
    $mode                       = undef,
    $owner                      = undef,
    $provider                   = undef,
    $purge                      = undef,
    $recurse                    = undef,
    $recurselimit               = undef,
    $replace                    = undef,
    $selinux_ignore_defaults    = undef,
    $selrange                   = undef,
    $selrole                    = undef,
    $seltype                    = undef,
    $seluser                    = undef,
    $show_diff                  = undef,
    $source                     = undef,
    $source_permissions         = undef,
    $sourceselect               = undef,
    $target                     = undef,
    $template                   = undef,
    $subst                      = {}
) {
    if $ensure {
        # The ensure parameter must be one of: present, absent, file, link
        validate_re($ensure,'^(present|absent|file|link)$')
    }
    # Prevent from providing mutually-exclusive parameters.
    if $source and $content {
        fail('source and content are mutually exclusive')
    }
    if $source and $target {
        fail('source and target are mutually exclusive')
    }
    if $source and $template {
        fail('source and template are mutually exclusive')
    }
    if $content and $target {
        fail('content and target are mutually exclusive')
    }
    if $content and $template {
        fail('content and template are mutually exclusive')
    }
    if $target and $template {
        fail('target and template are mutually exclusive')
    }
    if $subst {
        validate_hash($subst)
    }

    # Prepare file's contents.
    if $template  {
        # Template uses:
        #   - $subst
        $_content = template($template)
    } else {
        $_content = $content
    }

    # All attributes that can eventually be passed to the file resource.
    $_all_attribs = {
        path                    => $path,
        ensure                  => $ensure,
        backup                  => $backup,
        checksum                => $checksum,
        content                 => $_content,
        force                   => $force,
        group                   => $group,
        ignore                  => $ignore,
        links                   => $links,
        mode                    => $mode,
        owner                   => $owner,
        provider                => $provider,
        purge                   => $purge,
        recurse                 => $recurse,
        recurselimit            => $recurselimit,
        replace                 => $replace,
        selinux_ignore_defaults => $selinux_ignore_defaults,
        selrange                => $selrange,
        selrole                 => $selrole,
        seltype                 => $seltype,
        seluser                 => $seluser,
        show_diff               => $show_diff,
        source                  => $source,
        source_permissions      => $source_permissions,
        sourceselect            => $sourceselect,
        target                  => $target
    }

    # Leave only defined attributes, so the defaults will be chosen by the
    # 'file' resource type for the undefined ones.
    $_attribs = apachex_delete_undef_values($_all_attribs)

    # Create the config file.
    create_resources(file, {"$title" => $_attribs})
}
