require 'test/unit'
require_relative 'calculator'

class TestCalculator < Test::Unit::TestCase
  def test_returns_zero_for_empty_string
    assert_equal(0, add(''))
  end

  def test_returns_sum_of_two_numbers
    assert_equal(8, add('1,7'))
  end

  def test_returns_sum_of_several_numbers
    assert_equal(20, add('1,7,2,2,5,3'))
  end

  def test_returns_sum_with_new_lines
    assert_equal(20, add("1,7,2,2\n5,3"))
  end

  def test_returns_sum_with_delimiter
    test = <<-EOF
;
1;2;3
EOF
    assert_equal(6, add(test))
  end

end
