# == Define: apachex::conf_wrapper
#
# Provides convenient way to declare apachex::conf.
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
# [*content*]
#   The desired contents of a file, as a string. This attribute is mutually
#   exclusive with source and target.
#   For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-content.
#
# [*source*]
#   A source file, which will be copied into place on the local system.
#   For details see documentation of the file resource at
#   http://docs.puppetlabs.com/references/latest/type.html#file-attribute-source.
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
#   A hash defining parameters to be substituted in the configuration file.
#
# [*file_params*]
#   Other parameters to be passed to file resource.
#
# === Variables
#
# The apachex::conf_wrapper defines following defaults:
#
# TODO:
#
# The apachex::conf_wrapper requires following variables:
#
# TODO:
#
# === Examples
#
#       apachex::conf_wrapper{'/etc/apache2/mods-available/authz_core.load':
#           ensure         => file,
#           template       => 'apachex/debian/mods-available/module.load',
#           subst          =>  { 
#               'mod_id'   => 'authz_core_module',
#               'mod_path' => '/usr/lib/apache2/modules/mod_authz_core.so'
#           }
#           file_params     => {
#               owner       => 'root',
#               group       => 'root',
#               mode        => 'a=r,gu+w'
#           }
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
define apachex::conf_wrapper(
    $path           = undef,
    $ensure         = undef,
    $content        = undef,
    $source         = undef,
    $target         = undef,
    $template       = undef,
    $subst          = undef,
    $file_params    = {}
) {
    validate_hash($file_params)

    $_all_attribs = merge($file_params, {
        path     => $path,
        ensure   => $ensure,
        content  => $content,
        source   => $source,
        target   => $target,
        template => $template,
        subst    => $subst
    })

    $_attribs = apachex_delete_undef_values($_all_attribs)

    create_resources('apachex::conf', {"$title" => $_attribs})
}
