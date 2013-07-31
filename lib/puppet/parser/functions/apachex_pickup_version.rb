require 'puppet/util/package'
def pickup_version(package, version, repo_versions)
  version = version.split('.')
  vsize = version.size

  candidates = []
  repo_versions.lines.each do |line|
    fields = line.split(/\s+/)
    if fields.size() >= 2 and fields[0] == package
      fields[1..fields.size].each do |repover_string|
        repover = repover_string.split('.')
        return version if version == repover
        if vsize < repover.size and version == repover[0..(vsize-1)]
          candidates.push(repover_string)
        end
      end
    end
  end

  current = nil
  candidates.each do |candidate|
    if current.nil? or Puppet::Util::Package.versioncmp(candidate, current) > 0
      current = candidate
    end
  end
  return current
end

module Puppet::Parser::Functions
  newfunction(:apachex_pickup_version, :type => :rvalue, :doc => <<-EOS
Decide which version of a package should be installed.

This function takes a package name, a preferred version number and a formatted
list of available packages and their versions, and selects the best suited
version. If one, for example, wants 2.2 version apache2, whereas a system
repository provides apache2 2.2.1-1 and 2.2.2-1, then 2.2.2-1 will be returned.
If it's not possible to select version (for example if there is no candidate to
install), the function returns nil.

*Example:*
    
    $ver = apachex_pickup_version('apache2', '2.2', $::apachex_repo_versions)

The first argument contains package name. The second argument contains
preffered version of the package. The third argument contains is a string 
describing available packages and their versions:

  package1 ver1 ver2 ...
  package2 ver1 ver2 ...

The third argument may also be nil or :undef. 

Returns nil, if no matching version can be found.

      EOS
  ) do |args|

    raise(Puppet::ParseError,
          "apachex_pickup_version(): Wrong number of arguments given " +
          "(#{args.size})") if args.size < 3

    return nil if args[2].nil? or args[2].equal?(:undef)

    n = 1
    args.each do |arg|
      raise(Puppet::ParseError, 
            "apachex_pickup_version(): Wrong argument type #{args.class} " +
            "for argument #{n}") if not arg.is_a?(String)
      n = n +1
    end

    return pickup_version(args[0], args[1], args[2])
  end
end
