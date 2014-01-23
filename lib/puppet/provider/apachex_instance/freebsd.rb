require 'puppet/provider/apachex_instance'

Puppet::Type.type(:apachex_instance).provide :freebsd,
  :parent => Puppet::Provider::ApachexInstance do

  defaultfor :osfamily => :freebsd
end
