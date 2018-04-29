require 'active_support/all'
require 'nokogiri'

# https://stackoverflow.com/questions/2583472/regex-to-validate-json
JSON_REGEXP = /(
  # define subtypes and build up the json syntax, BNF-grammar-style
  # The {0} is a hack to simply define them as named groups here but not match on them yet
  # I added some atomic grouping to prevent catastrophic backtracking on invalid inputs
  (?<number>  -?(?=[1-9]|0(?!\d))\d+(\.\d+)?([eE][+-]?\d+)?){0}
  (?<boolean> true | false | null ){0}
  (?<string>  " (?>[^"\\\\]* | \\\\ ["\\\\bfnrt\/] | \\\\ u [0-9a-f]{4} )* " ){0}
  (?<array>   \[ (?> \g<json> (?: , \g<json> )* )? \s* \] ){0}
  (?<pair>    \s* \g<string> \s* : \g<json> ){0}
  (?<object>  \{ (?> \g<pair> (?: , \g<pair> )* )? \s* \} ){0}
  (?<json>    \s* (?> \g<number> | \g<boolean> | \g<string> | \g<array> | \g<object> ) \s* ){0}
)
\A \g<json> \Z
/uix

h1 = {a: 1, b: {c: 2, d: {e: 3}}}
h2 = {a: 1, b: {c: 2, d: {e: 3}, e: 4}, e: 5}

h3 = {a: [1,2,{b: [3,4,5,{c: 6}]}]}
h4 = {a: [1,2,{b: [3,4,5,{c: 6}], c: 7}]}

class Object
  def to_data
    ParsedData.new self, :hash
  end
end

class ParsedData
  attr_accessor :source

  def initialize(data, data_type = nil)
    @source = parse(data)
  end

  def method_missing(mth, *args, &block)
    m = mth.to_s
    if @source.respond_to? mth
      process @source.send(mth, *args, &block)
    elsif m =~ /\S+=/
      deep_set(m.gsub(/=/, ''), @source, args[0])
    else
      deep_get(m, @source)
    end
  end

  private
  def deep_get(key, obj, found = nil)
    if obj.respond_to?(:key?) && obj.key?(key)
      return process(obj[key])
    elsif obj.respond_to?(:each)
      obj.find { |*a| found = deep_get(key, a.last) }
      return found
    end
  end

  def deep_set(key, obj, value, found = nil)
    if obj.respond_to?(:key?) && obj.key?(key)
      obj[key] = value
      return value
    elsif obj.respond_to?(:each)
      obj.find { |*a| found = deep_set(key, a.last, value) }
      return found
    end
  end

  def parse(data)
    if data.is_a? String
      case data
      when /[[:space:]]*\<\?xml/
        @source = Hash.from_xml(data).with_indifferent_access
      when JSON_REGEXP
        @source = JSON.parse(data)
      else
        nil
      end
    elsif data.is_a? Hash
      @source = data.with_indifferent_access
    elsif data.is_a? Array
      @source = data
    elsif data.respond_to? :to_h
      @source = data.to_h
    else
      nil
    end
  end

  def parse!(data)
    unless tmp = parse(data)
      raise ArgumentError, "Unable to convert #{data.class} into a ParsedData object."
    end
  end

  def process(data)
    if data.is_a?(Hash) || data.is_a?(Array)
      data.to_data
    else
      data
    end
  end
end
