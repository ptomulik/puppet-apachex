require 'facter/util/ptomulik/apachex'
module Puppet::Parser::Functions
  newfunction(:apachex_pickup_version, :type => :rvalue, :doc => <<-EOT
    Decide which version of an apache package should be installed.

    This function takes a package name, a preferred version number and a
    formatted list of available packages and their versions, and selects the
    best suited version. If one, for example, wants 2.2 version of apache2,
    whereas a system repository provides apache2 2.2.1-1 and 2.2.2-1, then
    2.2.2-1 will be returned.

    If it's not possible to select version (for example if there is no
    candidate to install), the function returns nil.

    *Example:*
        
        $ver = apachex_pickup_version('apache2', '2.2', $::apachex_repo_versions)

    The first argument contains package name. The second argument contains
    preffered version of the package. The third argument contains is a string 
    describing available packages and their versions:

      package1 ver1 ver2 ...
      package2 ver1 ver2 ...

    The third argument may also be nil or :undef. 

    Returns nil, if no matching version can be found.
  EOT
  ) do |args|

    if (args.size < 3) or (args.size > 4)
      raise Puppet::ParseError, "apachex_pickup_version(): Wrong number of " +
        "arguments given (#{args.size} for 3)"
    end

    return nil if args[2].nil? or args[2].equal?(:undef)

    n = 1
    args.each do |arg|
      raise(Puppet::ParseError, 
            "apachex_pickup_version(): Wrong argument type #{arg.class} " +
            "for argument #{n}") if not arg.is_a?(String)
      n = n +1
    end

    Facter::Util::PTomulik::Apachex.pickup_version(*args)
  end
end
