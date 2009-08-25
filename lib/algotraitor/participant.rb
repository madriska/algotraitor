module Algotraitor
  Overdrawn = Class.new(StandardError)
  NoShortSelling = Class.new(StandardError)

  class Participant
    attr_reader :id, :name, :cash_balance, :portfolio

    def initialize(id, name, cash_balance)
      @id = id
      @name = name
      @cash_balance = cash_balance
      @portfolio = Hash.new(0)
    end

    def buy(stock, quantity)
      purchase_price = stock.price * quantity
      raise ArgumentError, "Quantity must be nonnegative" if quantity < 0
      raise Overdrawn if purchase_price > @cash_balance
      @cash_balance -= purchase_price
      @portfolio[stock] += quantity
    end

    def sell(stock, quantity)
      sale_price = stock.price * quantity
      raise ArgumentError, "Quantity must be nonnegative" if quantity < 0
      raise NoShortSelling if @portfolio[stock] < quantity
      @portfolio[stock] -= quantity
      @cash_balance += sale_price
    end

  end

end
