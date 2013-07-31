# Fact: apachex_repo_versions
# Value: list of apache package names with their versions as available in
#        package repositories, the list is formatted as follows:
#
#        package version[ version[ ...]]

def debian_apachex_versions
  apt_cache = '/usr/bin/apt-cache'
  if !File.executable?(apt_cache)
    return nil
  end
  version_array = []
  packages = ['apache2']
  packages.each do |package|
    result = %x(#{apt_cache} show #{package})
    line_array = []
    result.each_line do |line|
      match = line.match(/^Version:\s*([^\s]+)\s*$/)
      line_array += match.captures if match
    end
    if not line_array.empty?
      line = package + ' ' + line_array.join(' ')
      version_array.push(line)
    end
  end
  return version_array.join("\n")
end


# NOTE: repo search may take few minutes. Give it 10 minutes (600 seconds).
Facter.add(:apachex_repo_versions, :timeout => 600) do
  setcode do
    case Facter.value('osfamily')
    when /Debian/
      versions = debian_apachex_versions
    when /FreeBSD/
      # NOTE: not sure how to search ports ...
      versions = nil
    when /RedHat/
    else
      # TODO: implement redhat_apachex_versions
      versions = nil
    end
  end
end
