require File.dirname(__FILE__) + '/helper'

class MarketTest < Test::Unit::TestCase
  setup do
    @market = Algotraitor::Market.new
  end

  test "newly initialized market should be empty" do
    market = Algotraitor::Market.new
    assert market.stocks.empty?
  end

  test "stocks are automatically indexed by their symbol" do
    stock = Algotraitor::Stock.new('ABCD', 30.00)
    @market.stocks << stock
    assert_equal stock, @market.stocks[stock.symbol]
  end

end
