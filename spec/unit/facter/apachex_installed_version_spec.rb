require 'spec_helper'
describe '$apachex_installed_version fact', :type => :fact do
  context "on SomeOS" do
    before :each do
      Facter.fact(:osfamily).stubs(:value).returns('SomeOS')
    end
    it "calls Facter::Util::PTomulik::Apachex.installed_version once with 'SomeOS'" do
      Facter::Util::PTomulik::Apachex.expects(:installed_version).once.with('SomeOS').returns(['foo','0.1.2'])
      Facter.value(:apachex_installed_version).should == ['foo','0.1.2'].to_pson
    end
  end
end
