require File.dirname(__FILE__) + '/helper'

class ParticipantTest < Test::Unit::TestCase

  test "accepts an ID, a name and cash balance" do
    participant = Algotraitor::Participant.new(123, "Mickey Mouse", 100.00)
    assert_equal 123, participant.id
    assert_equal "Mickey Mouse", participant.name
    assert_equal 100.00, participant.cash_balance
  end
  
  context "#buy, #sell" do
    setup do
      @participant = Algotraitor::Participant.new(1, "Mr. Blah", 100.00)
      @stock = Algotraitor::Stock.new('XYZ', 50.00)
    end

    test "buy is blocked if participant doesn't have the cash" do
      assert_raises(Algotraitor::Overdrawn) { @participant.buy(@stock, 50) }
      assert_nothing_raised { @participant.buy(@stock, 1) }
    end

    test "sell is blocked if participant doesn't have the stock" do
      assert_raises(Algotraitor::NoShortSelling) { @participant.sell(@stock, 50) }
      assert_nothing_raised { 
        @participant.buy(@stock, 1)
        @participant.sell(@stock, 1)
      }
    end

    test "changes the portfolio and cash balance" do
      old_quantity = @participant.portfolio[@stock]
      old_balance = @participant.cash_balance
      
      result = @participant.buy(@stock, 1)
      
      # buy and sell return the execution price of the trade
      assert_equal(result[:price_per_share], @stock.price)
      assert_equal(@participant.cash_balance, old_balance - @stock.price)
      assert_equal(@participant.portfolio[@stock], old_quantity + 1)

      result = @participant.sell(@stock, 1)

      assert_equal(result[:price_per_share], @stock.price)
      assert_equal(@participant.cash_balance, old_balance)
      assert_equal(@participant.portfolio[@stock], old_quantity)
    end

    test "notifies subscribers of buys" do
      watcher = mock
      watcher.expects(:after_trade).with do |options|
        options[:participant] == @participant &&
          options[:stock].symbol == @stock.symbol &&
          options[:price] == @stock.price &&
          options[:quantity] == 2
      end

      @participant.add_observer(watcher)
      @participant.buy(@stock, 2)
      @participant.delete_observer(watcher)
    end

    test "notifies subscribers of sells" do
      watcher = mock
      watcher.expects(:after_trade).with do |options|
        options[:participant] == @participant &&
          options[:stock].symbol == @stock.symbol &&
          options[:price] == @stock.price &&
          options[:quantity] == -2
      end

      # make sure we have the stock to sell first
      @participant.buy(@stock, 2)

      @participant.add_observer(watcher)
      @participant.sell(@stock, 2)
      @participant.delete_observer(watcher)
    end

    test "can use before_trade to modify execution price" do
      watcher = mock
      watcher.expects(:before_trade).returns(:price => 5.00)

      @participant.add_observer(watcher)
      balance = @participant.cash_balance
      @participant.buy(@stock, 1)
      assert_equal @participant.cash_balance, balance - 5.00
      @participant.delete_observer(watcher)
    end

    test "balance modified in before_trade will overdraw if greater than cash balance" do
      watcher = mock
      watcher.expects(:before_trade).returns(:price => 
        @participant.cash_balance + 100.00)

      @participant.add_observer(watcher)
      assert_raises(Algotraitor::Overdrawn) { @participant.buy(@stock, 1) }
      @participant.delete_observer(watcher)
    end

  end

end
