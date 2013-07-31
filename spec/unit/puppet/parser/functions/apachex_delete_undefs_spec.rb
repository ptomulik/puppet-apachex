#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the apachex_delete_undefs function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    Puppet::Parser::Functions.function("apachex_delete_undefs").should == "function_apachex_delete_undefs"
  end

  it "should raise a ParseError if there is less than 1 argument" do
    lambda { scope.function_apachex_delete_undefs([]) }.should( raise_error(Puppet::ParseError))
  end

  it "should raise a ParseError if the argument is not Array nor Hash" do
    lambda { scope.function_apachex_delete_undefs(['']) }.should( raise_error(Puppet::ParseError))
    lambda { scope.function_apachex_delete_undefs([nil]) }.should( raise_error(Puppet::ParseError))
  end

  it "should delete :undef values from Array" do
    result = scope.function_apachex_delete_undefs([['a',:undef,'c']])
    result.should(eq(['a','c']))
  end

  it "should delete :undef values from Hash" do
    result = scope.function_apachex_delete_undefs([{'a'=>'A', 'b' => :undef, 'c' => 'C'}])
    result.should(eq({'a'=>'A','c'=>'C'}))
  end
end
