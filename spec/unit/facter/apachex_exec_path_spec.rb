require 'spec_helper'

describe '$apachex_exec_path fact', :type => :fact do
  context "on SomeOS" do
    before :each do
      Facter.fact(:osfamily).stubs(:value).returns('SomeOS')
    end
    it "calls Facter::Util::PTomulik::Apachex.exec_path once with 'SomeOS'" do
      Facter::Util::PTomulik::Apachex.expects(:exec_path).once.with('SomeOS').returns(:ok)
      Facter.value(:apachex_exec_path).should be :ok
    end
  end
end
