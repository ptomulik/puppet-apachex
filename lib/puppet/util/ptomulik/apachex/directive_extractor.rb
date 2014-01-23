require 'net/http'
require 'rexml/document'
require 'yaml'
require 'pathname'

require 'puppet/util/ptomulik/apachex'

module Puppet::Util::PTomulik::Apachex
class DirectiveExtractor

  include REXML

  attr_accessor :use_http
  attr_accessor :base_url
  attr_accessor :base_dir
  attr_writer :directives

  def directives
    @directives ||= {}
    @directives
  end

  def sorted_directives(recursive = true,&block)
    @directives.sort_by_key(recursive,&block)
  end

  def clear
    @directives = {}
  end

  def initialize(options)
    self.use_http = options[:use_http] ? true : false
    self.base_url = options[:base_url] if options[:base_url]
    self.base_dir = options[:base_dir] if options[:base_dir]
  end

  def read_file(file)
    if base_url
      file = "#{self.base_url}/#{file}"
    end
    if base_dir and not Pathname.new(file).absolute?
      file = File.join(base_dir,file)
    end
    if self.use_http
      Net::HTTP.get_response(URI.parse(file)).body
    else
      File.read(file)
    end
  end

  # Parse all files listed in an xml file ('allmodules.xml' by default).
  def parse_allmodules_file(file = 'allmodules.xml')
    string = read_file(file)
    parse_allmodules_xml(string)
  end

  def parse_allmodules_xml(string)
    rexmldoc = Document.new(string)
    parse_allmodules_doc(rexmldoc)
  end

  def parse_allmodules_doc(rexmldoc)
    rexmldoc.elements.each('modulefilelist/modulefile') do |element|
      parse_modulefile_file(element.text)
    end
    true
  end

  def parse_modulefiles(modulefiles)
    modulefiles.each do |modulefile|
      parse_modulefile_file(modulefile)
    end
    true
  end

  def parse_modulefile_file(file)
    string = read_file(file)
    parse_modulefile_xml(string)
  end

  def parse_modulefile_xml(string)
    doc = Document.new(string)
    parse_modulefile_doc(doc)
  end

  def parse_modulefile_doc(rexmldoc)
    rexmldoc.elements.each('modulesynopsis') do |modulesynopsis|
      parse_modulesynopsis(modulesynopsis)
    end
    true
  end

  def parse_modulesynopsis(modulesynopsis)
    # caonincalize module name
    modulename = modulesynopsis.elements['name'].text
    modulename = self.class.canon_modulename(modulename)
    modulesynopsis.elements.each('directivesynopsis') do |directivesynopsis|
      parse_directivesynopsis(directivesynopsis,modulename)
    end
    true
  end

  def parse_directivesynopsis(directivesynopsis,modulename)
    directivename = directivesynopsis.elements['name'].text
    directivename = self.class.canon_directivename(directivename)
    directives[directivename] ||= {}
    directive = directives[directivename]
    directive[:modules] ||= []
    directive[:modules] << modulename

    # DirectiveSynopsis sections thath have 'location' attribute refer to other
    # modules, where the directive is implemented, or such.
    return true if directivesynopsis.attributes['location']

    directive[:module] = modulename
    if type = directivesynopsis.attributes['type']
      directive[:type] = type
    end
    if description = directivesynopsis.elements['description']
      parse_directive_description(directive,description)
    end
    if default = directivesynopsis.elements['default']
      parse_directive_default(directive,default)
    end
    if syntax = directivesynopsis.elements['syntax']
      parse_directive_syntax(directive,syntax)
    end
    if status = directivesynopsis.elements['status']
      parse_directive_status(directive,status)
    end
    if contextlist = directivesynopsis.elements['contextlist']
      parse_directive_contextlist(directive,contextlist)
    end
    true
  end

  def parse_directive_description(directive,description)
    directive[:description] = description.flat_text_value
  end

  def parse_directive_default(directive,default)
    directive[:default] = default.flat_text_value
  end

  def parse_directive_syntax(directive,syntax)
    directive[:syntax] = syntax.flat_text_value
  end

  def parse_directive_status(directive,status)
    directive[:status] = status.flat_text_value
  end

  def parse_directive_contextlist(directive,contextlist)
    directive[:contextlist] ||= []
    contextlist.each_element('context') do |context|
      directive[:contextlist] << self.class.canon_contextname(context.text)
    end
    directive[:contextlist].sort!
  end

  def self.canon_contextname(s)
    s.downcase.sub(/^\./,'').sub(/[^\w]/,'_').intern
  end

  def self.canon_directivename(s)
    s.downcase.intern
  end

  def self.canon_modulename(s)
    s.downcase.intern
  end

end
end
