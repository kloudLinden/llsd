require 'rexml/document'
require 'date'

# Class for parsing and generating llsd xml
class LLSD
  class SerializationError < StandardError; end

  LLSD_ELEMENT = 'llsd'

  BOOLEAN_ELEMENT = 'boolean'
  INTEGER_ELEMENT = 'integer'
  REAL_ELEMENT = 'real'
  UUID_ELEMENT = 'uuid'
  STRING_ELEMENT = 'string'
  BINARY_ELEMENT = 'binary'
  DATE_ELEMENT = 'date'
  URI_ELEMENT = 'uri'
  KEY_ELEMENT = 'key'
  UNDEF_ELEMENT = 'undef'

  ARRAY_ELEMENT = 'array'
  MAP_ELEMENT = 'map'

  # PARSING AND ENCODING FUNCTIONS

  def self.to_xml(obj)
    llsd_element = REXML::Element.new LLSD_ELEMENT
    llsd_element.add_element(serialize_ruby_obj(obj))

    doc = REXML::Document.new
    doc << llsd_element
    doc.to_s
  end

  def self.to_notation(obj)
    @object_binary = ""
    notatize_ruby_obj(obj)
    @object_binary[@object_binary.length-2]='' #remove last comma
    @object_binary[@object_binary.length-1]='' #remove unwanted new line
    @object_binary
  end

  def self.append(data)
    @object_binary << data
  end

  def self.stop
    append ",\n"
  end

  private
  def self.notatize_ruby_obj(obj)
    case obj
    when Hash
      append "{\n"
      obj.each do |key, value|
        append "'"
        append key.to_s
        append "':"
        notatize_ruby_obj(value)
      end
      @object_binary[@object_binary.length-2]='' #remove last comma
      append "}"
      stop

    when Array
      append "[\n"
      obj.each { |o| notatize_ruby_obj(o) }
      @object_binary[@object_binary.length-2]='' #remove last comma
      append "]"
      stop

    when Fixnum, Integer
      append "i"
      append obj.to_s
      stop

    when TrueClass, FalseClass
      append obj ? "true" : "false"
      stop

    when Float
      append "r" << obj.to_s
      stop

    when Date, Time, DateTime
      append "d\""
      append obj.strftime('%Y-%m-%dT%H:%M:%SZ')
      append "\""
      stop

    when String
      append "\"" << obj.to_s << "\""
      stop

    when NilClass
      append '!'
      stop

    else
      raise SerializationError, "#{obj.class.to_s} class cannot be serialized into llsd xml - please serialize into a string first"
    end
  end

  def self.serialize_ruby_obj(obj)
    # if its a container (hash or map)

    case obj
    when Hash
      map_element = REXML::Element.new(MAP_ELEMENT)
      obj.each do |key, value|
        key_element = REXML::Element.new(KEY_ELEMENT)
        key_element.text = key.to_s
        value_element = serialize_ruby_obj value

        map_element.add_element key_element
        map_element.add_element value_element
      end

      map_element

    when Array
      array_element = REXML::Element.new(ARRAY_ELEMENT)
      obj.each { |o| array_element.add_element(serialize_ruby_obj(o)) }
      array_element

    when Fixnum, Integer
      integer_element = REXML::Element.new(INTEGER_ELEMENT)
      integer_element.text = obj.to_s
      integer_element

    when TrueClass, FalseClass
      boolean_element = REXML::Element.new(BOOLEAN_ELEMENT)

      if obj
        boolean_element.text = 'true'
      else
        boolean_element.text = 'false'
      end

      boolean_element

    when Float
      real_element = REXML::Element.new(REAL_ELEMENT)
      real_element.text = obj.to_s
      real_element

    when Date
      date_element = REXML::Element.new(DATE_ELEMENT)
      date_element.text = obj.new_offset(of=0).strftime('%Y-%m-%dT%H:%M:%SZ')
      date_element

    when String
      if !obj.empty?
        string_element = REXML::Element.new(STRING_ELEMENT)
        string_element.text = obj.to_s
        string_element
      else
        STRING_ELEMENT
      end

    when NilClass
      UNDEF_ELEMENT

    else
      raise SerializationError, "#{obj.class.to_s} class cannot be serialized into llsd xml - please serialize into a string first"
    end
  end

  
end
