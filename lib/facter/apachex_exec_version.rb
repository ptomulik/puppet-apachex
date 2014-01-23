# Fact: 'apachex_exec_version'
# Value: version returned by 'httpd -v' or nil (fact absent)
require 'facter/util/ptomulik/apachex'
Facter.add(:apachex_exec_version, :timeout => 5) do
  setcode do
    osfamily = Facter.value(:osfamily)
    Facter::Util::PTomulik::Apachex.exec_version(osfamily)
  end
end
