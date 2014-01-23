#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:apachex_instance).provider(:freebsd) do
  let(:resource_class) { Puppet::Type.type(:apachex_instance) }
  context "with default parameters" do
    let(:resource) do
      resource_class.new :name => 'foo', :provider => described_class.name
    end
    let(:provider) { resource.provider }
  end
end
