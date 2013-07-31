module Puppet::Parser::Functions
  newfunction(:apachex_delete_undefs, :type => :rvalue, :doc => <<-EOS
Returns a copy of input hash or array with all undefs deleted.

*Examples:*
    
    $hash = apachex_delete_undefs({a=>'A', b=>'', c=>undef, d => false})

Would return: {a => 'A', b => '', d => false}

    $array = apachex_delete_undefs(['A','',undef,false])

Would return: ['A','',false]

*Example:* 

A flexible apache package (for FreeBSD)

    # modules/apache/package.pp
    class apache::package (
        $adminfile = undef,
        $allowcdrom = undef,
        $configfiles = undef,
        $flavor = undef,
        $install_options = undef,
        $instance = undef,
        $package = undef,
        $ensure = undef,
        $platform = undef,
        $provider = undef,
        $responsefile = undef,
        $root = undef,
        $source = undef,
        $uninstall_options = undef,
        $version = undef,
    ){
      
      if $package
        $package_name = $package
      else
        # define $package_name in some smart way
        $package_name = $ensure ? {
          '2.4'   => 'www/apache24',
          default => 'www/apache22'
        }
      end 

      if $ensure =~ /^2\.[0-9]+$/ {
        $package_ensure = present
      } else {
        $package_ensure = $ensure
      }

      $all_params = {
        adminfile         => $adminfile,
        allowcdrom        => $allowcdrom,
        configfiles       => $configfiles,
        ensure            => $package_ensure,
        flavor            => $flavor,
        install_options   => $install_options,
        instance          => $instance,
        name              => $package_name,
        platform          => $platform,
        responsefile      => $responsefile,
        root              => $root,
        source            => $source,
        uninstall_options => $uninstall_options,
      }

      $params = apachex_delete_undefs($all_params)
      ensure_resource('package', 'apache', $params)
    }

In site.pp:
    
    class {'apache::package': ensure => '2.4' } # install apache24
    # or
    # class {'apache::package': } # install apache22
    # or
    # class {'apache::package': package => 'www/apache22'}
    
      EOS
    ) do |args|

    raise(Puppet::ParseError,
          "apachex_delete_undefs(): Wrong number of arguments given " +
          "(#{args.size})") if args.size < 1

    result = args[0]
    if result.is_a?(Hash)
      result.delete_if {|key, val| val.equal? :undef}
    elsif result.is_a?(Array)
      result.delete :undef
    else
      raise(Puppet::ParseError, 
            "apachex_delete_undefs(): Wrong argument type #{args[0].class} " +
            "for argument 1")
    end
    return result
  end
end
