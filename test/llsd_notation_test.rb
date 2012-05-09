require 'test_helper'

class LLSDNotationUnitTest2 < Test::Unit::TestCase
  def test_map
    multi_data_explode = <<EOF
[i5,{'asd':"asdstr",'test':[i4,r4.0]},"astring"]
EOF

    ruby_map_exploded = <<EOF
{'foo':"bar"}
EOF

    ruby_map_within_map_exploded = <<EOF
{'doo':{'goo':"poo"}}
EOF

    ruby_map = {:foo => 'bar'}
    ruby_map_within_map = {'doo' => {'goo' => 'poo'}}
    multi_data = [5, {asd: "asdstr", test: [4, 4.0]}, "astring"]
    ruby_blank_map = {}

    assert_equal ruby_map_exploded.strip, LLSD.to_notation(ruby_map)
    assert_equal ruby_map_within_map_exploded.strip, LLSD.to_notation(ruby_map_within_map)
    assert_equal multi_data_explode.strip, LLSD.to_notation(multi_data)
  end

  def test_array
    ruby_array_exploded = <<EOF
["foo","bar"]
EOF

    ruby_array_within_array_exploded = <<EOF
["foo","bar",["foo","bar"]]
EOF

    blank_array_xml = <<EOF
    <llsd>
      <array/>
    </llsd>
EOF

    ruby_array = ['foo', 'bar']
    ruby_array_within_array = ['foo', 'bar', ['foo', 'bar']]
    ruby_blank_array = []

    assert_equal ruby_array_exploded.strip, LLSD.to_notation(ruby_array)
    assert_equal ruby_array_within_array_exploded.strip, LLSD.to_notation(ruby_array_within_array)
  end

  def test_string
    assert_equal "\"foo\"", LLSD.to_notation("foo")
    assert_equal "\"\"", LLSD.to_notation("")
  end

  def test_integer
    ruby_pos_int = 289343
    ruby_neg_int = -289343

    assert_equal "i#{ruby_pos_int.to_s}", LLSD.to_notation(ruby_pos_int)#.strip.gsub(/\n|"/,'')
    assert_equal "i#{ruby_neg_int.to_s}", LLSD.to_notation(ruby_neg_int)
  end

  def test_real
    ruby_pos_real = 2983287453.38483
    ruby_neg_real = -2983287453.38483

    assert_equal "r#{ruby_pos_real}", LLSD.to_notation(ruby_pos_real)
    assert_equal "r#{ruby_neg_real}", LLSD.to_notation(ruby_neg_real)
  end

  def test_boolean
    assert_equal "true", LLSD.to_notation(true)
    assert_equal "false", LLSD.to_notation(false)
  end

  def test_date
    ruby_valid_date = DateTime.now #strptime('2006-02-01T14:29:53Z')
    ruby_blank_date = DateTime.now #strptime('1970-01-01T00:00:00Z')

    assert_equal "d\"#{ruby_valid_date.strftime('%Y-%m-%dT%H:%M:%SZ')}\"", LLSD.to_notation(ruby_valid_date)
    assert_equal "d\"#{ruby_blank_date.strftime('%Y-%m-%dT%H:%M:%SZ')}\"", LLSD.to_notation(ruby_blank_date)

  end

  def test_nil
    assert_equal "!", LLSD.to_notation(nil)
  end

  def test_llsd_serialization_exception
    # make an object not supported by llsd
    ruby_range = Range.new 1, 2

    # assert than an exception is raised
    assert_raise(LLSD::SerializationError) { LLSD.to_notation(ruby_range) }
  end

end
