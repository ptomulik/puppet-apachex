class Hash
  def sort_by_key(recursive=false, &block)
    self.keys.sort(&block).reduce({}) do |seed, key|
      seed[key] = self[key]
      if recursive && seed[key].is_a?(Hash)
        seed[key] = seed[key].sort_by_key(true, &block)
      end
      seed
    end
  end
end

require 'rexml/element'
require 'rexml/xpath'
class REXML::Element
  def inner_texts
    REXML::XPath.match(self,'.//text()')
  end

  def inner_text
    inner_texts.map{|e| e.to_s}.join
  end

  def inner_text_value
    inner_texts.map{|e| e.value}.join
  end

  def flat_text
    inner_text.gsub(/\s+/m,' ').strip
  end

  def flat_text_value
    inner_text_value.gsub(/\s+/m,' ').strip
  end
end
