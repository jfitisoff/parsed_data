require_relative 'version'
require_relative 'constants'
require_relative 'object'

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
      if tmp = find_parent(m.gsub(/=/, ''), @source)
        process(tmp[m.gsub(/=/, '')] = args[0])
      else
        process(@source[m.gsub(/=/, '')] = args[0])
      end
    else
      process(deep_get(m, @source))
    end
  end

  private
  def find_parent(key, obj, found = nil)
    if obj.respond_to?(:key?) && obj.key?(key)
      return obj
    elsif obj.respond_to?(:each)
      obj.find { |*a| found = find_parent(key, a.last) }
      return found
    end
  end

  def deep_get(key, obj, found = nil)
    if obj.respond_to?(:key?) && obj.key?(key)
      return obj[key]
    elsif obj.respond_to?(:each)
      obj.find do |*a|
        found = deep_get(key, a.last)
      end
      return found
    end
  end

  def parse(data)
    if data.is_a? String
      case data
      when XML_REGEXP
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
