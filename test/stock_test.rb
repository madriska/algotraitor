require File.dirname(__FILE__) + '/helper'

class StockTest < Test::Unit::TestCase
  
  test "initializer takes stock and initial price as arguments" do
    stock = Algotraitor::Stock.new("ABC", 15.00)
    assert_equal "ABC", stock.symbol
    assert_equal 15.00, stock.price
  end

end
