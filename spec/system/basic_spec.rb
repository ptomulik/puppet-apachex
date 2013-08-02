require 'spec_helper_system'

describe 'basic tests:' do
  context 'make sure we have copied the module across' do
    # FIXME: where the files would be copied on FreeBSD?
    context shell "ls /etc/puppet/modules/apachex" do
      its(:stdout) {should =~ /Modulefile/}
      its(:stderr) {should be_empty}
      its(:exit_code) {should be_zero}
    end
  end
end
