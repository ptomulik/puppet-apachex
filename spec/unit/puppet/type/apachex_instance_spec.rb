#! /usr/bin/env ruby
require 'spec_helper'

Puppet::Type.type(:apachex_instance).provide :dummy, :parent => Puppet::Provider do
end

describe Puppet::Type.type(:apachex_instance) do
  context 'when validating attributes' do
    [
      :name,
      :modules,
    ].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
  end

  context 'when validating attribute values' do
    before do
      @provider = stub(
        'provider',
        :class => described_class.defaultprovider,
        :provider => :dummy
      )
      described_class.defaultprovider.stubs(:new).returns(@provider)
##      #
##      # Our resource type uses facts, so we stub ones to avoid surprises
##      #
##      Facter.stubs(:value).with(:apachex_root_user).returns 'rootuser'
##      Facter.stubs(:value).with(:apachex_root_group).returns 'rootgroup'
    end

    describe "name" do
      [10,{},[],'0asd','-34sf','foo%'].each do |value|
        context "with {name => #{value.inspect}}" do
          let(:resource) { described_class.new :name => value }
          it do
            expect { resource }.to raise_error Puppet::ResourceError,
                /Invalid value #{Regexp.escape(value.inspect)}/
          end
        end
      end
      ['foo','f100','f__','_adf', '____'].each do |value|
        context "with {name => #{value.inspect}}" do
          let(:resource) { described_class.new :name => value }
          let(:value) { value }
          it { expect { resource }.to_not raise_error }
          it "should set name to #{value.inspect}" do
            resource.value(:name).should == value
          end
        end
      end
    end

    describe "modules" do
      [10,{},[]].each do |value|
        context "with {modules => #{value.inspect}}" do
          let(:resource) { described_class.new :name => 'foo', :modules => value }
          let(:value) { value }
          it do
            expect { resource }.to raise_error Puppet::ResourceError,
                /modules must be a String, not #{Regexp.escape(value.class.to_s)}/
          end
        end
      end
      ['foo','f100','f__','_adf', '____'].each do |value|
        context "with {modules => #{value.inspect}}" do
          let(:resource) { described_class.new :name => 'foo', :modules => value }
          let(:value) { value }
          it { expect { resource }.to_not raise_error }
          it "should set modules to #{value.inspect}" do
            resource.value(:modules).should == value
          end
        end
      end
      context "default value" do
        ['foo','bar'].each do |value|
          context "with {name => #{value.inspect}}" do
            let(:resource) { described_class.new(:name => value)  }
            let(:value) { value }
            it { resource.value(:modules).should == value }
          end
        end
      end
    end

##    describe "apache_name" do
##      [10,{},[],'','3.4','_._._','@%','Apache'].each do |value|
##        context "apache_name => #{value.inspect}" do
##          let(:resource) { described_class.new :name => 'foo', :apache_name => value }
##          let(:value) { value }
##          it do
##            expect { resource }.to raise_error Puppet::ResourceError,
##                /Invalid value #{Regexp.escape(value.inspect)}/
##          end
##        end
##      end
##      [
##        'apache',
##        'apache2',
##        'apache22',
##        'apache24',
##        'http',
##        'httpd',
##        'httpd2'
##      ].each do |value|
##        context "apache_name => #{value.inspect}" do
##          let(:resource) { described_class.new :name => 'foo', :apache_name => value }
##          let(:value) { value }
##          it { expect { resource }.to_not raise_error }
##          it "should set value of apache_name parameter to #{value.inspect}" do
##            resource.value(:apache_name).should == value
##          end
##        end
##      end
##    end
##
##    describe "apache_version" do
##      [10,{},[],'','.3.4','3.4.','_._._','@%'].each do |value|
##        context "apache_version => #{value.inspect}" do
##          let(:resource) { described_class.new :name => 'foo', :apache_version => value }
##          let(:value) { value }
##          it do
##            expect { resource }.to raise_error Puppet::ResourceError,
##                /Invalid value #{Regexp.escape(value.inspect)}/
##          end
##        end
##      end
##      ['2.2', '2.2.26', '2.2.26-1', '2.2.26_1,234'].each do |value|
##        context "apache_version => #{value.inspect}" do
##          let(:resource) { described_class.new :name => 'foo', :apache_version => value }
##          let(:value) { value }
##          it { expect { resource }.to_not raise_error }
##          it "should set value of apache_version parameter to #{value.inspect}" do
##            resource.value(:apache_version).should == value
##          end
##        end
##      end
##    end
##
##    [:user, :group].each do |what|
##      fact_name = "apachex_root_#{what}".intern
##      fact_value = "root#{what}"
##      describe "#{what}" do
##        let(:what) { what }
##        [10,{},[]].each do |value|
##          context "#{what} => #{value.inspect}" do
##            let(:resource) { described_class.new :name => 'foo', what => value }
##            let(:value) { value }
##            it do
##              expect { resource }.to raise_error Puppet::ResourceError,
##                  /#{what} must be a String, not #{value.class}/
##            end
##          end
##        end
##        ["some-#{what}"].each do |value|
##          context "#{what} => #{value.inspect}" do
##            let(:resource) { described_class.new :name => 'foo', what => value }
##            let(:value) { value }
##            it { expect { resource }.to_not raise_error }
##            it "should set value of #{what} parameter to #{value.inspect}" do
##              resource.value(what).should == value
##            end
##          end
##        end
##        context "default value" do
##          context "when Facter.value(:#{fact_name}) == #{fact_value.inspect}" do
##            let(:resource) { described_class.new(:name => 'foo')  }
##            let(:value) { fact_value }
##            it { resource.value(what).should == value }
##          end
##        end
##      end
##    end
##
    describe "instance_options" do
      [10,[],"a string"].each do |value|
        context "instance_options => #{value.inspect}" do
          let(:value) { value }
          it do
            expect { described_class.new(:name => 'foo', :instance_options => value) }.
              to raise_error Puppet::ResourceError,
                /instance_options must be an Hash, not #{value.class}/
          end
        end
      end
      [
        {},
        {
          :foo  => 'bar',
          :geez => 10,
          :koo  => []
        },
      ].each do |value|
        context "instance_options => #{value.inspect}" do
          let(:resource) { described_class.new(:name => 'foo', :instance_options => value) }
          let(:value) { value }
          it { expect { resource }.to_not raise_error }
          it "should set value of instance_options #{value.inspect}" do
            resource.value(:instance_options).should == value
          end
        end
      end
    end
  end
end
