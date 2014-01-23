require 'puppet/resource'
require 'puppet/util/package'

module Facter; module Util; module PTomulik; end; end; end
# Utility methods used by apachex-related facter facts.
module Facter::Util::PTomulik::Apachex

  def self.default_exec_paths_hash
    {
      :archlinux => '/usr/sbin/apachectl',
      :debian    => '/usr/sbin/apache2',
      :freebsd   => '/usr/local/sbin/httpd',
      :redhat    => '/usr/sbin/httpd',
    }
  end

  def self.default_package_names_hash
    {
      :archlinux => [
        'apache'
      ],
      :debian  => [
        'apache2'
      ],
      :freebsd => [
        'www/apache22',
        'www/apache22-event-mpm',
        'www/apache22-itk-mpm',
        'www/apache22-peruser-mpm',
        'www/apache22-worker-mpm',
        'www/apache24'
      ],
      :redhat => [
        'httpd'
      ]
    }
  end

  # Typical locations of apache executable on supported OSes (absolute paths).
  #
  # @param osfamily [String|Symbol] value of the osfamily fact
  # @return [Hash] a hash in form `{os=>path}`
  def self.default_exec_paths(osfamily)
    osfamily = osfamily.downcase.intern if osfamily.is_a?(String)
    default_exec_paths_hash[osfamily]
  end

  # List package names that provide the apache httpd server on supported OSes.
  #
  # The package names listed by {default_package_names} are the ones that are
  # typically available in OS's package repositories.
  #
  # @param osfamily [String|Symbol] value of the osfamily fact
  # @return [Hash]
  def self.default_package_names(osfamily)
    osfamily = osfamily.downcase.intern if osfamily.is_a?(String)
    default_package_names_hash[osfamily]
  end

  # Parse the output of `httpd -v` command.
  #
  # @param output [String] text printed by `httpd -v` command
  # @return [String|nil] version, e.g. `2.2.26`.
  #
  def self.parse_version_output(output)
    version = nil
    output.each_line do |line|
      if line.match(/^Server version/)
        version_array = line.scan(/Apache\/([0-9]+\.[0-9]+.*) /)
        if version_array.size < 1 or version_array[0].size < 1
          version = nil
        else
          version = version_array[0][0]
        end
      end
    end
    return version
  end

  # Find an absolute path of apache executable.
  #
  # This first tries to find `apache2ctl` or `apachectl` executable on the
  # current OS. If this fails, it fall-backs to hard-coded defaults (see
  # {default_exec_paths}. If none of the `{default_exec_paths}[os]` is an
  # executable file, `nil` is returned`.
  #
  # @param osfamily [String] value of $osfamily fact for current OS 
  # @return [String|nil]
  #
  def self.exec_path(osfamily)
    ['apache2ctl', 'apachectl'].each do |prog|
      path = Facter::Util::Resolution.which(prog)
      return path if path
    end

    # Fallback to hard-coded paths
    path = default_exec_paths(osfamily)
    return path if path and File.file?(path) and File.executable?(path)
    nil
  end

  # Find installed version of apache package.
  # 
  # This uses Puppet::Resource to find if the apache package is installed and
  # in which version. If the package isn't installed, it returns `nil`.
  #
  # @param osfamily [String] value of $osfamily fact for current OS 
  # @return [Array|nil] two element array in form `[name,version]`
  #
  def self.installed_version(osfamily)
    names = default_package_names(osfamily)
    return nil unless names
    names.each do |name|
      package = Puppet::Resource.indirection.find("package/#{name}")
      if package.is_a?(Puppet::Resource) and package[:ensure] =~ /^[0-9]+\./
        return [name,package[:ensure]]
      end
    end
    nil
  end

  # Retrieve the version of apache executable.
  #
  # @param osfamily [String] value of $osfamily fact for current OS
  # @return [String|nil] the version of apache executable as printed by `httpd
  #   -v`, if apache is not installed or the module is unable to find apache
  #   executable returns `nil`
  def self.exec_version(osfamily)
    if httpd = exec_path(osfamily)
      output = Facter::Util::Resolution.exec("#{httpd} -v")
      parse_version_output(output) 
    else
      nil
    end
  end

  # Username of the root (administrator) user
  #
  # @param osfamily [String] value of $osfamily fact for current OS
  # @return [String] root's username (login)
  def self.root_user(osfamily)
    case osfamily
    when 'Debian','FreeBSD'; 'root'
    else
      raise NotImplementedError, "#{osfamily} is not supported"
    end
  end

  # Main group of the root (administrator) user
  #
  # @param osfamily [String] value of $osfamily fact for current OS
  # @return [String] root's main group (login)
  def self.root_group(osfamily)
    case osfamily
    when 'Debian'; 'root'
    when 'FreeBSD'; 'wheel'
    else
      raise NotImplementedError, "#{osfamily} is not supported"
    end
  end

  # Select one from the available versions of apache package.
  #
  # @todo write documentation
  # @param package [String]
  # @param version [String]
  # @param repo_versions [Hash] a hash in form `{package => versions}`, where
  #   `package` is a string (e.g. `"apache2"`) and `versions` is an array of
  #   versions available for installation from a repository
  # @return [String]
  def self.pickup_version(package, version, repo_versions)
    version = version.split('.')
    vsize = version.size

    candidates = []
    repo_versions.each_line do |line|
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
end
