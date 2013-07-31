require 'spec_helper'

describe 'apachex_exec_version fact:', :type => :fact do

  httpd = '/usr/sbin/apache2ctl'
  context "if apachex_exec is '#{httpd}'" do

    before :each do
      File.stubs(:file?).with(httpd).returns(true)
      File.stubs(:executable?).with(httpd).returns(true)
      Facter.fact(:apachex_exec).stubs(:value).returns(httpd)
    end

    { 
      '2.4.6'   => '2.4.6',
      'abc'     => nil,     # ill-formed version number (unacceptable)
      ''        => nil      # empty - just for case
    }.each do |vers, expect|
      expect_str =  expect.nil? ? 'nil' : "'#{expect}'"
      context "and '#{httpd} -v' returns '#{vers}'" do
        output = "Server version: Apache/#{vers} (Debian)\n" + \
                 "Server built:   Jul 23 2013 11:42:21\n"
        before :each do
          Facter::Util::Resolution.stubs(:exec).with("#{httpd} -v").returns(output)
        end
        it "should return #{expect_str}" do
          Facter.value(:apachex_exec_version).should == expect
        end
      end
    end

    context "and '#{httpd} -v' outputs ill-formed string" do
      output = "2.4.6\n"
      before :each do
        Facter::Util::Resolution.stubs(:exec).with("#{httpd} -v").returns(output)
      end
      it "should return nil" do
        Facter.value(:apachex_exec_version).should == nil
      end
    end

    context "and '#{httpd} -v' outputs empty line" do
      output = "\n"
      before :each do
        Facter::Util::Resolution.stubs(:exec).with("#{httpd} -v").returns(output)
      end
      it "should return nil" do
        Facter.value(:apachex_exec_version).should == nil
      end
    end

  end

end
