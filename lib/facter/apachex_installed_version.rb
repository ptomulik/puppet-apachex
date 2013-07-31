require 'puppet/resource'

Facter.add(:apachex_installed_version, :timeout => 20) do
  setcode do
    package_version = nil
    case Facter.value(:osfamily)
    when /Debian/
      names = ['apache2']
    when /FreeBSD/
      names =  ['www/apache22', 'www/apache24']
    when /RedHat/
      names = ['httpd']
    end
    names.each do |name|
      package = Puppet::Resource.indirection.find("package/#{name}")
      if package.is_a? Puppet::Resource and package[:ensure] =~ /^[0-9]+\./
        package_version = "#{name} #{package[:ensure]}"
        break
      end
    end
    package_version
  end
end
