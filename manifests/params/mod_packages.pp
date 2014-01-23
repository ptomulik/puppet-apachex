class apachex::params::mod_packages {
  case $::osfamily {
    'archlinux': {
      $value = {
        'auth_kerb'  => 'mod_auth_kerb',
        'fcgid'      => 'mod_fcgid',
        'passenger'  => 'passenger',
        'perl'       => 'mod_perl',
        'php5'       => ['php', 'php-apache'],
        'python'     => 'mod_python',
        'wsgi'       => 'mod_wsgi',
        'xsendfile'  => 'mod_xsendfile',
      }
    }
    'debian': {
      $value = {
        'auth_kerb'  => 'libapache2-mod-auth-kerb',
        'fcgid'      => 'libapache2-mod-fcgid',
        'passenger'  => 'libapache2-mod-passenger',
        'perl'       => 'libapache2-mod-perl2',
        'php5'       => 'libapache2-mod-php5',
        'proxy_html' => 'libapache2-mod-proxy-html',
        'python'     => 'libapache2-mod-python',
        'wsgi'       => 'libapache2-mod-wsgi',
        'dav_svn'    => 'libapache2-svn',
        'suphp'      => 'libapache2-mod-suphp',
        'xsendfile'  => 'libapache2-mod-xsendfile',
      }
    }
    'freebsd': {
      $value = {
        # NOTE: I list here only modules that are not included in www/apache22
        # NOTE: 'passenger' needs to enable APACHE_SUPPORT in make config
        # NOTE: 'php' needs to enable APACHE option in make config
        # NOTE: 'dav_svn' needs to enable MOD_DAV_SVN in make config
        # NOTE: don't know where the shibboleth module should come from
        'auth_kerb'  => 'www/mod_auth_kerb2',
        'fcgid'      => 'www/mod_fcgid',
        'passenger'  => 'www/rubygem-passenger',
        'perl'       => 'www/mod_perl2',
        'php5'       => 'lang/php5',
        'proxy_html' => 'www/mod_proxy_html',
        'python'     => 'www/mod_python3',
        'wsgi'       => 'www/mod_wsgi',
        'dav_svn'    => 'devel/subversion',
        'xsendfile'  => 'www/mod_xsendfile',
      }
    }
    'redhat': {
      $value = {
        'auth_kerb'  => 'mod_auth_kerb',
        'fcgid'      => 'mod_fcgid',
        'passenger'  => 'mod_passenger',
        'perl'       => 'mod_perl',
        'php5'       => $distrelease ? {
          '5'     => 'php53',
          default => 'php',
        },
        'proxy_html' => 'mod_proxy_html',
        'python'     => 'mod_python',
        'shibboleth' => 'shibboleth',
        'ssl'        => 'mod_ssl',
        'wsgi'       => 'mod_wsgi',
        'dav_svn'    => 'mod_dav_svn',
        'suphp'      => 'mod_suphp',
        'xsendfile'  => 'mod_xsendfile',
      }
    }
  }
}
