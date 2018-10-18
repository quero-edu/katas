require 'test/unit'
require_relative 'calculator'

class TestCalculator < Test::Unit::TestCase
  def test_returns_zero_for_empty_string
    assert_equal(0, add(''))
  end
end
