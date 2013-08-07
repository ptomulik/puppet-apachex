describe 'apachex::package tests:' do
  let(:os) {
    node.facts['osfamily']
  }

  case node.facts['osfamily']
  when 'Debian'
    default_package = 'apache2'
  when 'FreeBSD'
    default_package = 'www/apache22'
  when 'RedHat'
    default_package = 'httpd'
  end

  context 'uninstall apache package (initial cleanup)' do
    pp = <<-EOS
      class { 'apachex::package': ensure => absent }
    EOS
    context puppet_apply(pp) do
      its(:stderr) { should be_empty }
    end
  end
  describe package(default_package) do
    it { should_not be_installed }
  end


  context 'install default apache package - idempotent' do
    pp = <<-EOS
      include apachex::package
    EOS
    context puppet_apply(pp) do
      its(:stderr) { should be_empty }
      its(:exit_code) { should == 2 }
      its(:refresh) { should be_nil }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end
  describe package(default_package) do
    it { should be_installed }
  end

  context 'uninstall apache package - idempotent' do
    pp = <<-EOS
      class { 'apachex::package': ensure => absent }
    EOS
    context puppet_apply(pp) do
      its(:stderr) { should be_empty }
      its(:exit_code) { should == 2 }
      its(:refresh) { should be_nil }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end
  describe package(default_package) do
    it { should_not be_installed }
  end


  # Try to install each version available in repository
  repo_versions = [ '2.2' ]
  repo_versions.each do |ver|
    context "install apache #{ver} - idempotent" do
      pp = <<-EOS
        class { 'apachex::package': ensure => '#{ver}' }
      EOS
      context puppet_apply(pp) do
        its(:stderr) { should be_empty }
        its(:exit_code) { should == 2 }
        its(:refresh) { should be_nil }
        its(:stderr) { should be_empty }
        its(:exit_code) { should be_zero }
      end
    end
    context 'uninstall apache package (final cleanup) - idempotent' do
      pp = <<-EOS
        class { 'apachex::package': ensure => absent }
      EOS
      context puppet_apply(pp) do
        its(:stderr) { should be_empty }
        its(:exit_code) { should == 2 }
        its(:refresh) { should be_nil }
        its(:stderr) { should be_empty }
        its(:exit_code) { should be_zero }
      end
    end
  end
end
