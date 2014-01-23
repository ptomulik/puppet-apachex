require 'puppet/util/ptomulik/apachex'

module Puppet::Util::PTomulik::Apachex
module DirectiveValidator
  def self.protocols(s)
    [
      'ftp',
      'http',
      'https',
      'nntp',
    ]
  end
  def self.accept_filters(s);
    [
    ]
  end
  def self.matches_regexp?(s,re); s =~ re; end
  def self.is_protocol?(s); protocols.include?(s); end
  def self.is_accept_filter?(s); end

  def self.validate_accept_filter(args)
    unless args.instance_of?(Array) and args.length == 2
      raise ArgumentError,
        "expected [protocol,accept_filter], got #{args.inspect}"
    end
  end
end
end
