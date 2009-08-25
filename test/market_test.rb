require File.dirname(__FILE__) + '/helper'

class MarketTest < Test::Unit::TestCase
  setup do
    @market = Algotraitor::Market.new
    @stock = Algotraitor::Stock.new('ABC', 15.00)
    @market.stocks << @stock
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

  test "participants are indexed by their ID" do
    participant = Algotraitor::Participant.new(12, "Mr. Blah", 100.00)
    @market.participants << participant
    assert_equal participant, @market.participants[participant.id]
  end

  test "Market#stock_prices returns a hash mapping symbols to current prices" do
    @stock.price = 12.34
    assert_equal @stock.price, @market.stock_prices[@stock.symbol]
  end

  test "Plugging a Strategy into a market informs it of price changes" do
    strategy = mock
    strategy.expects(:update_stock_price).with {
      |stock, time, old_price, new_price|
      stock == @stock &&
        new_price == old_price + 1.0
    }

    @market.strategies << strategy

    @stock.price += 1.0
  end

  test "a strategy doesn't have to subscribe to update_stock_price" do
    strategy = mock

    @market.strategies << strategy

    assert_nothing_raised { @stock.price += 1.0 }
  end


end
