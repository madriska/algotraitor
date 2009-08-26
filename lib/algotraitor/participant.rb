require 'thread'

module Algotraitor
  Overdrawn = Class.new(StandardError)
  NoShortSelling = Class.new(StandardError)

  class Participant
    include Observable

    def initialize(id, name, cash_balance)
      @id = id
      @name = name
      @cash_balance = cash_balance
      @portfolio = Hash.new(0)
      @mutex = Mutex.new
    end

    attr_reader :id, :name, :cash_balance, :portfolio

    # FIXME: bit of a security hole here
    def valid_password?(password)
      password == 'kittens'
    end

    def buy(stock, quantity)
      purchase_price = stock.price * quantity
      raise ArgumentError, "Quantity must be nonnegative" if quantity < 0
      raise Overdrawn if purchase_price > @cash_balance
      
      if quantity > 0
        @mutex.synchronize do
          @cash_balance -= purchase_price
          @portfolio[stock] += quantity
        end

        changed
        notify_observers(self, Time.now, stock.price, quantity)
      end
    end

    def sell(stock, quantity)
      sale_price = stock.price * quantity
      raise ArgumentError, "Quantity must be nonnegative" if quantity < 0
      raise NoShortSelling if @portfolio[stock] < quantity

      if quantity > 0
        @mutex.synchronize do
          @portfolio[stock] -= quantity
          @cash_balance += sale_price
        end

        changed
        notify_observers(self, Time.now, stock.price, -quantity)
      end
    end

  end

end
