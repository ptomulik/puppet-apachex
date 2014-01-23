require 'spec_helper'

describe '$apachex_root_group fact', :type => :fact do
  context "on SomeOS" do
    before :each do
      Facter.fact(:osfamily).stubs(:value).returns('SomeOS')
    end
    it "calls Facter::Util::PTomulik::Apachex.root_group once with 'SomeOS'" do
      Facter::Util::PTomulik::Apachex.expects(:root_group).once.with('SomeOS').returns(:ok)
      Facter.value(:apachex_root_group).should be :ok
    end
  end
end
