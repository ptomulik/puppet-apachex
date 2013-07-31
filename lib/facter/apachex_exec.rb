# Fact: 'apachex_exec'
# Value: Path to the httpd executable, or empty string.

Facter.add(:apachex_exec) do
  setcode do

    httpd = nil

    ['apache2ctl', 'apachectl'].each do |prog|
      path = Facter::Util::Resolution.which(prog)
      if not path.nil?
        httpd = path
        break
      end
    end

    if httpd.nil?
      default_paths = {
        'Debian'  => '/usr/sbin/apache2',
        'FreeBSD' => '/usr/local/sbin/httpd',
        'RedHat'  => '/usr/sbin/httpd',
      }
      default_paths.default = nil
      path = default_paths[Facter.value('osfamily')]
      if not path.nil? and File.file?(path) and File.executable?(path)
        httpd = path
      end
    end
    httpd

  end
end
