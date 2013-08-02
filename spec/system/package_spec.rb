describe 'apachex::package tests:' do
  context 'uninstall apache package (initial cleanup)' do
    pp = <<-EOS
      class { 'apachex': include_package => false }
      class { 'apachex::package': ensure => absent }
    EOS
    context puppet_apply(pp) do
      its(:stderr) { should be_empty }
    end
  end
  context 'install default apache package - idempotent' do
    pp = <<-EOS
      class { 'apachex': include_package => false }
      include apachex::package
    EOS
    context puppet_apply(pp) do
      its(:stderr) { should be_empty }
      its(:exit_code) { should == 2 }
      its(:refresh) { should be_nil }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
    context shell "facter -p" do
      its(:exit_code) { should be_zero }
#      its(:stdout) { should =~ /^apachex_installed_version\s*=>\s*2\./ }
    end
  end
  context 'uninstall apache package - idempotent' do
    pp = <<-EOS
      class { 'apachex': include_package => false }
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
  # Try installing different versions of apache
  ['2.2'].each do |ver|
    context "install apache #{ver} - idempotent" do
      pp = <<-EOS
        class { 'apachex': include_package => false }
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
#    context shell "facter -p | grep apachex_installed_version" do
#      its(:exit_code) { should be_zero }
#      its(:stdout) { should =~ /^apachex_installed_version\s*=>\s*#{ver}/ }
#    end
  end
  context 'uninstall apache package (final cleanup) - idempotent' do
    pp = <<-EOS
      class { 'apachex': include_package => false }
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
