# Fact: 'apachex_exec'
# Value: Path to the httpd executable, or empty string.

require 'facter/util/ptomulik/apachex'

Facter.add(:apachex_exec_path) do
  setcode do
    osfamily = Facter.value(:osfamily)
    Facter::Util::PTomulik::Apachex.exec_path(osfamily)
  end
end
