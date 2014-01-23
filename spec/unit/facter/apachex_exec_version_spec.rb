require 'spec_helper'

describe '$apachex_exec_version fact', :type => :fact do
  context 'on SomeOS' do
    before :each do
      Facter.fact(:osfamily).stubs(:value).returns('SomeOS')
    end
    it "calls Facter::Util::PTomulik::Apachex.exec_version once with 'SomeOS'" do
      Facter::Util::PTomulik::Apachex.expects(:exec_version).once.with('SomeOS').returns(:ok)
      Facter.value(:apachex_exec_version).should be :ok
    end
  end
end
