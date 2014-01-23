#! /usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'../lib'))

require 'puppet/util/ptomulik/apachex/directive_extractor'

if ARGV.length > 0 and ARGV[0] != 'trunk'
  svn_subdir = "tags/#{ARGV[0]}"
else
  svn_subdir = 'trunk'
end

httpd_svn = 'http://svn.apache.org/repos/asf/httpd/httpd'
options = {
  :use_http => 'true',
  :base_url => "#{httpd_svn}/#{svn_subdir}/docs/manual/mod"
}

xtractor = Puppet::Util::PTomulik::Apachex::DirectiveExtractor.new(options)
xtractor.parse_allmodules_file

require 'yaml'
require 'puppet/util/ptomulik/apachex/monkey_patches.rb'
puts xtractor.sorted_directives.to_yaml
