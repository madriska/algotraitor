require 'thread'

module Algotraitor
  Overdrawn = Class.new(StandardError)
  NoShortSelling = Class.new(StandardError)

  class Participant
    def initialize(id, name, cash_balance)
      @id = id
      @name = name
      @cash_balance = cash_balance
      @portfolio = Hash.new(0)
      @mutex = Mutex.new
      @observers = []
    end

    attr_reader :id, :name, :cash_balance, :portfolio

    # FIXME: bit of a security hole here
    def valid_password?(password)
      password == 'kittens'
    end

    def add_observer(observer)
      @observers << observer
    end

    def delete_observer(observer)
      @observers.delete(observer)
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

        @observers.each do |observer|
          if observer.respond_to?(:after_trade)
            observer.after_trade(:participant => self, 
                                 :stock => stock, 
                                 :time => executed_at, 
                                 :price => stock.price, 
                                 :quantity => quantity)
          end
        end
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

        @observers.each do |observer|
          if observer.respond_to?(:after_trade)
            observer.after_trade(:participant => self, 
                                 :stock => stock, 
                                 :time => executed_at, 
                                 :price => stock.price, 
                                 :quantity => -quantity)
          end
        end
      end

      {:price_per_share => execution_price,
       :executed_at     => executed_at}
    end

  end

end
