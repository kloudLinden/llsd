$:.unshift File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'llsd'

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

def parse(xml_string)
  # turn message into dom element
  doc = REXML::Document.new xml_string

  # get the first element inside the llsd element
  # if there is more than one element then return nil

  # return parse dom element on first element
  parse_dom_element doc.root.elements[1]
end

def parse_dom_element(element)
    # pseudocode:

    #   if it is a container
    #     if its an array
    #       collect parse_dom_element applied to each child into an array
    #     else (its a map)
    #       collect parse_dom_element applied to each child into an hash
    #   else (its an atomic element)
    #     then extract the value to a native type
    #
    #   return the value

    case element.name
    when ARRAY_ELEMENT
      element_value = []
      element.elements.each {|child| element_value << (parse_dom_element child) }

    when MAP_ELEMENT
      element_value = {}
      element.elements.each do |child|
        if child.name == 'key'
          element_value[child.text] = parse_dom_element child.next_element
        end
      end

    else
      element_value = convert_to_native_type(element.name, element.text, element.attributes)
    end

    element_value
end

  def convert_to_native_type(element_type, unconverted_value, attributes)
    case element_type
    when INTEGER_ELEMENT
      unconverted_value.to_i

    when REAL_ELEMENT
      unconverted_value.to_f

    when BOOLEAN_ELEMENT
      if unconverted_value == 'false' or unconverted_value.nil? # <boolean />
        false
      else
        true
      end

    when STRING_ELEMENT
      if unconverted_value.nil? # <string />
        ''
      else
        unconverted_value
      end

    when DATE_ELEMENT
      if unconverted_value.nil?
        DateTime.strptime('1970-01-01T00:00:00Z')
      else
        DateTime.strptime(unconverted_value)
      end

    when UUID_ELEMENT
      if unconverted_value.nil?
        '00000000-0000-0000-0000-000000000000'
      else
        unconverted_value
      end

    else
      unconverted_value
    end
  end