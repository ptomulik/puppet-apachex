require 'facter/util/ptomulik/apachex'

Facter.add(:apachex_installed_version, :timeout => 20) do
  setcode do
    osfamily = Facter.value(:osfamily)
    Facter::Util::PTomulik::Apachex.installed_version(osfamily).to_pson
  end
end
