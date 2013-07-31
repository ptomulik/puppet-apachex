# Fact: 'apachex_exec_version'
# Value: version returned by 'httpd -v' or nil (fact absent)

def parse_version(version_string)
  version = nil
  version_string.each_line do |line|
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

Facter.add(:apachex_exec_version, :timeout => 5) do
  setcode do
    httpd = Facter.value(:apachex_exec)
    if not httpd.nil?
      version = parse_version(Facter::Util::Resolution.exec("#{httpd} -v")) 
    else
      version = nil
    end
  end
end
