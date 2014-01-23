# == Define: apachex::conf::httpd
#
# Main configuration file (the httpd.conf).
#
# === Parameters
#
# None
#
# === Variables
#
# The apachex::conf::httpd defines following defaults:
#
# [*foo*]
#   Foo variable
#
#
# The apachex::params requires following variables:
#
# [*::bar*]
#   Bar from facter
#
#
# === Examples
#
#  TODO:
#
# === Authors
#
# Pawel Tomulik <ptomulik@meil.pw.edu.pl>
#
# === Copyright
#
# Copyright 2014 Pawel Tomulik.
#
define apachex::conf::httpd(
    $instance           = undef,
    $path               = undef,
    $apache_version     = undef,
    $cgi_bin_dir        = apachex::params::cgi_bin_dir,
    $custom_log         = apachex::params::custom_log,
    $document_root      = apachex::params::document_root,
    $error_log          = apachex::params::error_log,
    $group              = apachex::params::group,
    $listen             = apachex::params::listen,
    $log_level          = apachex::params::log_level,
    $mime_default_type  = apachex::params::mime_default_type,
    $mod_dir            = apachex::params::mod_dir,
    $modules            = {},
    $server_admin       = apachex::params::server_admin,
    $server_root        = apachex::params::server_root,
    $template           = undef,
    $user               = apachex::params::user,
) inherits apachex::params {
    $_subst = {
        cgi_bin_dir         => $cgi_bin_dir,
        custom_log          => $custom_log,
        error_log           => $error_log,
        group               => $group,
        listen              => $listen,
        log_level           => $log_level,
        mime_default_type   => $mime_default_type,
        modules             => $modules,
        server_root         => $server_root,
        user                => $user,
    }
}
