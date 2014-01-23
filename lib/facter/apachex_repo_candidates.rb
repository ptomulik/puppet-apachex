# TODO: write some documentation for apachex_repo_candidates fact 
require 'puppet/util/repoutil'
require 'facter/util/ptomulik/apachex'

# NOTE: repo search may take few minutes. Give it 5 minute (300 seconds).
Facter.add(:apachex_repo_candidates, :timeout => 300) do
  setcode do
    osfamily = Facter.value('osfamily')
    packages = Facter::Util::PTomulik::Apachex.default_package_names(osfamily)
    if packages
      Puppet::Util::RepoUtils.package_candidates(packages).to_pson
    else
      []
    end
  end
end
