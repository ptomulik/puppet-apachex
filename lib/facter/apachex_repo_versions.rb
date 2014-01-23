# TODO: write some documentation for apachex_repo_versions fact 
require 'puppet/util/repoutil'
require 'facter/util/ptomulik/apachex'

# NOTE: repo search may take few minutes. Give it 5 minute (300 seconds).
Facter.add(:apachex_repo_versions, :timeout => 300) do
  setcode do
    case Facter.value('osfamily')
    when /Debian/
      packages = Puppet::Util::PTomulik::Apachex.debian_packages
      versions = debian_apachex_versions(packages)
    when /FreeBSD/, /OpenBSD/, /NetBSD/
      packages = Puppet::Util::PTomulik::Apachex.freebsd_packages
    when /RedHat/
      packages = Puppet::Util::PTomulik::Apachex.redhat_packages
    else
      packages = []
    end
    Puppet::Util::RepoUtils.package_versions(packages).to_pson
  end
end
