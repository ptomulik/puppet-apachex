if RUBY_VERSION >= '1.9'
  require 'coveralls'
  Coveralls.wear! do
    add_filter 'spec/'
    add_filter 'lib/puppet/provider/packagex.rb'
    add_filter 'lib/puppet/provider/packagex/openbsd.rb'
    add_filter 'lib/puppet/provider/packagex/freebsd.rb'
  end
end

require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |config|
  # FIXME REVISIT - We may want to delegate to Facter like we do in
  # Puppet::PuppetSpecInitializer.initialize_via_testhelper(config) because
  # this behavior is a duplication of the spec_helper in Facter.
  config.before :each do
    # Ensure that we don't accidentally cache facts and environment between
    # test cases.  This requires each example group to explicitly load the
    # facts being exercised with something like
    # Facter.collection.loader.load(:ipaddress)
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages
  end
end

# This module depends on:
#   - ptomulik/repoutil
mod_path = RSpec.configuration.module_path
$LOAD_PATH.unshift(File.join(mod_path,'repoutil/lib'))
