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
      execution_price = stock.price
      purchase_price = execution_price * quantity
      raise ArgumentError, "Quantity must be nonnegative" if quantity < 0
      raise Overdrawn if purchase_price > @cash_balance
      
      executed_at = nil
      if quantity > 0
        @mutex.synchronize do
          # Serialize the assignment to executed_at so the history is consistent
          executed_at = Algotraitor.timestamp
          @cash_balance -= purchase_price
          @portfolio[stock] += quantity
        end

        changed
        notify_observers(:participant => self, 
                         :stock => stock, 
                         :time => executed_at, 
                         :price => stock.price, 
                         :quantity => quantity)
      end

      {:price_per_share => execution_price,
       :executed_at     => executed_at}
    end

    def sell(stock, quantity)
      execution_price = stock.price
      sale_price = execution_price * quantity
      raise ArgumentError, "Quantity must be nonnegative" if quantity < 0
      raise NoShortSelling if @portfolio[stock] < quantity

      executed_at = nil
      if quantity > 0
        @mutex.synchronize do
          # Serialize the assignment to executed_at so the history is consistent
          executed_at = Algotraitor.timestamp
          @portfolio[stock] -= quantity
          @cash_balance += sale_price
        end

        changed
        notify_observers(:participant => self, 
                         :stock => stock, 
                         :time => executed_at, 
                         :price => stock.price, 
                         :quantity => -quantity)
      end

      {:price_per_share => execution_price,
       :executed_at     => executed_at}
    end

  end

end
