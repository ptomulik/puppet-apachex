require 'spec_helper'
require 'puppet/util/repoutil'

describe '$apachex_repo_candidates fact', :type => :fact do
  context "on SomeOS" do
    before :each do
      Facter.fact(:osfamily).stubs(:value).returns('SomeOS')
      Facter::Util::PTomulik::Apachex.stubs(:default_package_names).with('SomeOS').
        returns(['pkg1','pkg2'])
    end
    it "calls Facter::Util::PTomulik::Apachex.package_candidates once" do
      Puppet::Util::RepoUtils.expects(:package_candidates).once.with(['pkg1','pkg2']).returns({:ok => :OK})
      Facter.value(:apachex_repo_candidates).should == ({:ok => :OK}.to_pson)
    end
  end
end
