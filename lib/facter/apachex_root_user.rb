# Fact: 'apachex_root_user'
# Value: Username of the root user on given OS

require 'facter/util/ptomulik/apachex'

Facter.add(:apachex_root_user) do
  setcode do
    osfamily = Facter.value(:osfamily)
    Facter::Util::PTomulik::Apachex.root_user(osfamily)
  end
end
