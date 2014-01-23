# Fact: 'apachex_root_group'
# Value: Groupname of the root's main group on given OS

require 'facter/util/ptomulik/apachex'

Facter.add(:apachex_root_group) do
  setcode do
    osfamily = Facter.value(:osfamily)
    Facter::Util::PTomulik::Apachex.root_group(osfamily)
  end
end
