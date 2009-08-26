require File.dirname(__FILE__) + '/helper'

class StockTest < Test::Unit::TestCase
  setup do
    @stock = Algotraitor::Stock.new("XYZ", 1.00)
  end
  
  test "initializer takes stock and initial price as arguments" do
    stock = Algotraitor::Stock.new("ABC", 15.00)
    assert_equal "ABC", stock.symbol
    assert_equal 15.00, stock.price
  end

  test "notifies subscribers when price changes" do
    watcher = mock
    watcher.expects(:after_price_change).with do |options|
      options[:stock].symbol == 'XYZ' &&
        options[:new_price] = options[:old_price] + 1.0
    end

    @stock.add_observer(watcher)
    @stock.price += 1.0
    @stock.delete_observer(watcher)
  end

end
