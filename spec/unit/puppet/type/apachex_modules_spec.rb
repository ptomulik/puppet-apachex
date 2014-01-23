#! /usr/bin/env ruby
require 'spec_helper'

Puppet::Type.type(:apachex_modules).provide :dummy, :parent => Puppet::Provider do
end

describe Puppet::Type.type(:apachex_modules) do
  context 'when validating attributes' do
    [
      :name,
      :modules,
      :id_suffix,
    ].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
  end

  context 'when validating attribute values' do
    let(:provider) do
      stub(
        'provider',
        :class => described_class.defaultprovider,
        :provider => :dummy
      )
    end
    before do
      described_class.defaultprovider.stubs(:new).returns(provider)
      #
      # Our resource type uses facts, so we stub ones to avoid surprises
      #
      Facter.stubs(:value).with(:apachex_root_user).returns 'rootuser'
      Facter.stubs(:value).with(:apachex_root_group).returns 'rootgroup'
    end

    describe "name" do
      [10,{},[]].each do |value|
        context "with {name => #{value.inspect}}" do
          let(:resource) { described_class.new :name => value }
          let(:value) { value }
          it do
            expect { resource }.to raise_error Puppet::ResourceError,
                /name must be a String, not #{Regexp.escape(value.class.to_s)}/
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
      # Invlid type
      [10,[],"a string"].each do |value|
        context "modules => #{value.inspect}" do
          let(:resource) { described_class.new(:name => 'foo', :modules => value) }
          let(:value) { value }
          it do
            expect { resource }.to raise_error Puppet::ResourceError,
                /modules must be an Hash, not #{value.class}/
          end
        end
      end
      # Invalid key
      [
        [ { '' => 'mod_foo.so', }, '' ],
        [ { 'foo module' => 'mod_foo.so', }, 'foo module' ],
        [ { 'foo_module' => 'mod_foo.so',
            'bar module' => 'mod_bar.so', }, 'bar module' ]
      ].each do |value,mod|
        context "modules => #{value.inspect}" do
          let(:resource) { described_class.new(:name => 'foo', :modules => value) }
          let(:value) { value }
          let(:mod) { mod }
          it do
            expect { resource }.to raise_error Puppet::ResourceError,
                /Invalid module #{Regexp.escape(mod.inspect)}/
          end
        end
      end
      [
        [ { 'foo_module' => {}, }, ['foo_module',{}] ],
        [ { 'foo_module' => 10, }, ['foo_module',10] ],
        [ 
          {
            'foo_module' => 'mod_bar.so',
            'bar_module' => 10
          },
          ['bar_module',10]
        ],
      ].each do |value,modfile|
        context "modules => #{value.inspect}" do
          let(:resource) { described_class.new(:name => 'foo', :modules => value) }
          let(:value) { value }
          let(:mod) { modfile[0] }
          let(:file) { modfile[1] }
          it do
            msg = "Invalid filename #{Regexp.escape(file.inspect)} for " +
              "module #{Regexp.escape(mod.inspect)}"
            expect { resource }.to raise_error Puppet::ResourceError, /#{msg}/
          end
        end
      end
      [
        {},
        {
          :foo_module  => 'mod_foo.so',
          :bar_module  => '/usr/lib/apache2/modules/mod_bar.so'
        },
      ].each do |value|
        context "modules => #{value.inspect}" do
          let(:resource) { described_class.new(:name => 'foo', :modules => value) }
          let(:value) { value }
          it { expect { resource }.to_not raise_error }
          it "should set value of modules to #{value.inspect}" do
            resource.value(:modules).should == value
          end
        end
      end
    end

    describe "id_suffix" do
      [10,{},[]].each do |value|
        context "with {id_suffix => #{value.inspect}}" do
          let(:resource) { described_class.new :name => 'foo', :id_suffix => value }
          let(:value) { value }
          it do
            expect { resource }.to raise_error Puppet::ResourceError,
                /id_suffix must be a String, not #{Regexp.escape(value.class.to_s)}/
          end
        end
      end
      ['foo','f100','f__','_adf', '____'].each do |value|
        context "with {id_suffix => #{value.inspect}}" do
          let(:resource) { described_class.new :name => 'foo', :id_suffix => value }
          let(:value) { value }
          it { expect { resource }.to_not raise_error }
          it "should set id_suffix to #{value.inspect}" do
            resource.value(:id_suffix).should == value
          end
        end
      end
    end

    describe "id_map" do
      # Invlid type
      [10,[],"a string"].each do |value|
        context "id_map => #{value.inspect}" do
          let(:resource) { described_class.new(:name => 'foo', :id_map => value) }
          let(:value) { value }
          it do
            expect { resource }.to raise_error Puppet::ResourceError,
                /id_map must be an Hash, not #{value.class}/
          end
        end
      end
      # Invalid key
      [
        [ { '' => '_module', }, '' ],
        [ { 'fo o' => 'foo_module', }, 'fo o' ],
        [ { 'foo' => 'foo_module',
            'b ar' => 'bar_module', }, 'b ar' ]
      ].each do |value,mod|
        context "id_map => #{value.inspect}" do
          let(:resource) { described_class.new(:name => 'foo', :id_map => value) }
          let(:value) { value }
          let(:mod) { mod }
          it do
            expect { resource }.to raise_error Puppet::ResourceError,
                /Invalid module #{Regexp.escape(mod.inspect)}/
          end
        end
      end
      # Invalid value
      [
        [ { 'foo_module' => {}, }, ['foo_module',{}] ],
        [ { 'foo_module' => 10, }, ['foo_module',10] ],
        [ 
          {
            'foo' => 'foo_module',
            'bar' => 10
          },
          ['bar',10]
        ],
        [ 
          {
            'foo' => 'foo_module',
            'bar' => 'bar module'
          },
          ['bar','bar module']
        ],
      ].each do |value,modid|
        context "id_map => #{value.inspect}" do
          let(:resource) { described_class.new(:name => 'foo', :id_map => value) }
          let(:value) { value }
          let(:mod) { modid[0] }
          let(:id) { modid[1] }
          it do
            msg = "Invalid id #{Regexp.escape(id.inspect)} for " +
              "module #{Regexp.escape(mod.inspect)}"
            expect { resource }.to raise_error Puppet::ResourceError, /#{msg}/
          end
        end
      end
      # Valid keys and values
      [
        {},
        {
          :foo => 'foo_module',
          :bar => :bar_module
        },
      ].each do |value|
        context "id_map => #{value.inspect}" do
          let(:resource) { described_class.new(:name => 'foo', :id_map => value) }
          let(:value) { value }
          it { expect { resource }.to_not raise_error }
          it "should set value of id_map to #{value.inspect}" do
            resource.value(:id_map).should == value
          end
        end
      end
    end
  end
end
