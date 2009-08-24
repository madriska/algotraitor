require File.dirname(__FILE__) + '/helper'

class MarketTest < Test::Unit::TestCase
  
  test "newly initialized market should be empty" do
    market = Algotraitor::Market.new
    assert market.stocks.empty?
  end

end
