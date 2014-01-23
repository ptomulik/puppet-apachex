require 'spec_helper'

describe 'the apachex_pickup_version function' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'should exist' do
    function = Puppet::Parser::Functions.function('apachex_pickup_version')
    function.should == 'function_apachex_pickup_version'
  end

  # less than three arguments
  [[],['0'],['0','1']].each do |args|
    args_str = args.map{|x| x.inspect}.join(", ")
    context "apachex_pickup_version(#{args_str})" do
      let(:args) { args }
      it do
        msg = "Wrong number of arguments given (#{args.size} for 3)"
        expect { scope.function_apachex_pickup_version(args) }.
          to raise_error Puppet::ParseError, /#{Regexp::escape(msg)}/
      end
    end
  end
  
  # arguments with wrong type
  [
    [[nil,'',''],0], # arg 1 is not a string
    [['',nil,''],1], # arg 2 is not a string
  ].each do |args,no|
    args_str = args.map{|x| x.inspect}.join(", ")
    context "apachex_pickup_version(#{args_str})" do
      let(:args) { args }
      let(:no) { no }
      it do
        msg = "Wrong argument type #{args[no].class} for argument #{no+1}"
        expect { scope.function_apachex_pickup_version(args) }.
          to raise_error Puppet::ParseError, /#{Regexp::escape(msg)}/
      end
    end
  end

  [
    ['foo', '1.2.3', 'foo 1.2.3-2 5.4.3-2,3'],
  ].each do |args|
    args_str = args.map{|x| x.inspect}.join(", ")
    context "apachex_pickup_version(#{args_str})" do
      let(:args) { args }
      it "calls Facter::Util::PTomulik::Apachex.pickup_version(#{args}) once" do
        Facter::Util::PTomulik::Apachex.expects(:pickup_version).once.
          with(*args).returns :ok
        scope.function_apachex_pickup_version(args).should be :ok 
      end
    end
  end

end
