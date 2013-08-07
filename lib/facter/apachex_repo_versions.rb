# Fact: apachex_repo_versions
# Value: list of apache package names with their versions as available in
#        package repositories, the list is formatted as follows:
#
#        package version[ version[ ...]]

def debian_apachex_versions
  apt_cache = '/usr/bin/apt-cache'
  if not File.executable?(apt_cache)
    return nil
  end
  version_array = []
  packages = ['apache2']
  packages.each do |package|
    result = %x(#{apt_cache} show #{package})
    line_array = []
    result.chomp.each_line do |line|
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

def redhat_apachex_versions
  yum = '/usr/bin/yum'
  if not File.executable?(yum)
    return nil
  end
  version_array = []
  packages = ['httpd']
  packages.each do |package|
    result = %x(#{yum} -d 0 -e 0 -y list #{package})
    line_array = []
    result.chomp.each_line do |line|
      match = line.match(/^#{package}[^\s]*\s+([^\s]+)/)
      line_array += match.captures if match
    end
    if not line_array.empty?
      line = package + ' ' + line_array.join(' ')
      version_array.push(line)
    end
  end
  return version_array.join("\n")
end

def freebsd_apachex_versions
  # FIXME: this is far from perfect, why:
  # 1. portsdir shouldn't be hardcoded, we have bsd_ports_dir parameter in 
  #    apachex::package for example, and changing it from default value
  #    will break everything
  # 2. the list of possible packages shouldn't be hard-coded (they likely 
  #    will extend this list with new versions of apache); consider using 
  #    a command such as `ls -d /usr/ports/www/apache2*` + some extra
  #    filtering.
  if Facter.value('osfamily') == 'NetBSD'
    portsdir = '/usr/pkgsrc'
  else
    portsdir = '/usr/ports'
  end
  if not File.directory?(portsdir)
    return nil
  end

  make = '/usr/bin/make'
  if not File.executable?(make)
    return nil
  end

  version_array = []
  packages = [
    'www/apache22', 
    'www/apache22-event-mpm', 
    'www/apache22-itk-mpm',
    'www/apache22-peruser-mpm',
    'www/apache22-worker-mpm',
    'www/apache24'
  ]
  packages.each do |package|
    result = %x(cd #{portsdir}/#{package} && #{make} package-name)
    fields = result.chomp.split('-',2)
    if fields.size >= 2
      version = fields[1]
      version_array.push(package + ' ' + version)
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
    when /FreeBSD/, /OpenBSD/, /NetBSD/
      versions = freebsd_apachex_versions
    when /RedHat/
      versions = redhat_apachex_versions
    else
      versions = nil
    end
  end
end
